//===- FormatGen.cpp - Utilities for custom assembly formats ----*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "FormatGen.h"
#include "llvm/ADT/StringSwitch.h"
#include "llvm/Support/SourceMgr.h"
#include "llvm/TableGen/Error.h"

using namespace mlir;
using namespace mlir::tblgen;
using llvm::SourceMgr;

//===----------------------------------------------------------------------===//
// FormatToken
//===----------------------------------------------------------------------===//

SMLoc FormatToken::getLoc() const {
  return SMLoc::getFromPointer(spelling.data());
}

//===----------------------------------------------------------------------===//
// FormatLexer
//===----------------------------------------------------------------------===//

FormatLexer::FormatLexer(SourceMgr &mgr, SMLoc loc)
    : mgr(mgr), loc(loc),
      curBuffer(mgr.getMemoryBuffer(mgr.getMainFileID())->getBuffer()),
      curPtr(curBuffer.begin()) {}

FormatToken FormatLexer::emitError(SMLoc loc, const Twine &msg) {
  mgr.PrintMessage(loc, SourceMgr::DK_Error, msg);
  llvm::SrcMgr.PrintMessage(this->loc, SourceMgr::DK_Note,
                            "in custom assembly format for this operation");
  return formToken(FormatToken::error, loc.getPointer());
}

FormatToken FormatLexer::emitError(const char *loc, const Twine &msg) {
  return emitError(SMLoc::getFromPointer(loc), msg);
}

FormatToken FormatLexer::emitErrorAndNote(SMLoc loc, const Twine &msg,
                                          const Twine &note) {
  mgr.PrintMessage(loc, SourceMgr::DK_Error, msg);
  llvm::SrcMgr.PrintMessage(this->loc, SourceMgr::DK_Note,
                            "in custom assembly format for this operation");
  mgr.PrintMessage(loc, SourceMgr::DK_Note, note);
  return formToken(FormatToken::error, loc.getPointer());
}

int FormatLexer::getNextChar() {
  char curChar = *curPtr++;
  switch (curChar) {
  default:
    return (unsigned char)curChar;
  case 0: {
    // A nul character in the stream is either the end of the current buffer or
    // a random nul in the file. Disambiguate that here.
    if (curPtr - 1 != curBuffer.end())
      return 0;

    // Otherwise, return end of file.
    --curPtr;
    return EOF;
  }
  case '\n':
  case '\r':
    // Handle the newline character by ignoring it and incrementing the line
    // count. However, be careful about 'dos style' files with \n\r in them.
    // Only treat a \n\r or \r\n as a single line.
    if ((*curPtr == '\n' || (*curPtr == '\r')) && *curPtr != curChar)
      ++curPtr;
    return '\n';
  }
}

FormatToken FormatLexer::lexToken() {
  const char *tokStart = curPtr;

  // This always consumes at least one character.
  int curChar = getNextChar();
  switch (curChar) {
  default:
    // Handle identifiers: [a-zA-Z_]
    if (isalpha(curChar) || curChar == '_')
      return lexIdentifier(tokStart);

    // Unknown character, emit an error.
    return emitError(tokStart, "unexpected character");
  case EOF:
    // Return EOF denoting the end of lexing.
    return formToken(FormatToken::eof, tokStart);

  // Lex punctuation.
  case '^':
    return formToken(FormatToken::caret, tokStart);
  case ':':
    return formToken(FormatToken::colon, tokStart);
  case ',':
    return formToken(FormatToken::comma, tokStart);
  case '=':
    return formToken(FormatToken::equal, tokStart);
  case '<':
    return formToken(FormatToken::less, tokStart);
  case '>':
    return formToken(FormatToken::greater, tokStart);
  case '?':
    return formToken(FormatToken::question, tokStart);
  case '(':
    return formToken(FormatToken::l_paren, tokStart);
  case ')':
    return formToken(FormatToken::r_paren, tokStart);
  case '*':
    return formToken(FormatToken::star, tokStart);
  case '|':
    return formToken(FormatToken::pipe, tokStart);

  // Ignore whitespace characters.
  case 0:
  case ' ':
  case '\t':
  case '\n':
    return lexToken();

  case '`':
    return lexLiteral(tokStart);
  case '$':
    return lexVariable(tokStart);
  case '"':
    return lexString(tokStart);
  }
}

FormatToken FormatLexer::lexLiteral(const char *tokStart) {
  assert(curPtr[-1] == '`');

  // Lex a literal surrounded by ``.
  while (const char curChar = *curPtr++) {
    if (curChar == '`')
      return formToken(FormatToken::literal, tokStart);
  }
  return emitError(curPtr - 1, "unexpected end of file in literal");
}

FormatToken FormatLexer::lexVariable(const char *tokStart) {
  if (!isalpha(curPtr[0]) && curPtr[0] != '_')
    return emitError(curPtr - 1, "expected variable name");

  // Otherwise, consume the rest of the characters.
  while (isalnum(*curPtr) || *curPtr == '_')
    ++curPtr;
  return formToken(FormatToken::variable, tokStart);
}

FormatToken FormatLexer::lexString(const char *tokStart) {
  // Lex until another quote, respecting escapes.
  bool escape = false;
  while (const char curChar = *curPtr++) {
    if (!escape && curChar == '"')
      return formToken(FormatToken::string, tokStart);
    escape = curChar == '\\';
  }
  return emitError(curPtr - 1, "unexpected end of file in string");
}

FormatToken FormatLexer::lexIdentifier(const char *tokStart) {
  // Match the rest of the identifier regex: [0-9a-zA-Z_\-]*
  while (isalnum(*curPtr) || *curPtr == '_' || *curPtr == '-')
    ++curPtr;

  // Check to see if this identifier is a keyword.
  StringRef str(tokStart, curPtr - tokStart);
  auto kind =
      StringSwitch<FormatToken::Kind>(str)
          .Case("attr-dict", FormatToken::kw_attr_dict)
          .Case("attr-dict-with-keyword", FormatToken::kw_attr_dict_w_keyword)
          .Case("prop-dict", FormatToken::kw_prop_dict)
          .Case("custom", FormatToken::kw_custom)
          .Case("functional-type", FormatToken::kw_functional_type)
          .Case("oilist", FormatToken::kw_oilist)
          .Case("operands", FormatToken::kw_operands)
          .Case("params", FormatToken::kw_params)
          .Case("ref", FormatToken::kw_ref)
          .Case("regions", FormatToken::kw_regions)
          .Case("results", FormatToken::kw_results)
          .Case("struct", FormatToken::kw_struct)
          .Case("successors", FormatToken::kw_successors)
          .Case("type", FormatToken::kw_type)
          .Case("qualified", FormatToken::kw_qualified)
          .Default(FormatToken::identifier);
  return FormatToken(kind, str);
}

//===----------------------------------------------------------------------===//
// FormatParser
//===----------------------------------------------------------------------===//

FormatElement::~FormatElement() = default;

FormatParser::~FormatParser() = default;

FailureOr<std::vector<FormatElement *>> FormatParser::parse() {
  SMLoc loc = curToken.getLoc();

  // Parse each of the format elements into the main format.
  std::vector<FormatElement *> elements;
  while (curToken.getKind() != FormatToken::eof) {
    FailureOr<FormatElement *> element = parseElement(TopLevelContext);
    if (failed(element))
      return failure();
    elements.push_back(*element);
  }

  // Verify the format.
  if (failed(verify(loc, elements)))
    return failure();
  return elements;
}

//===----------------------------------------------------------------------===//
// Element Parsing
//===----------------------------------------------------------------------===//

FailureOr<FormatElement *> FormatParser::parseElement(Context ctx) {
  if (curToken.is(FormatToken::literal))
    return parseLiteral(ctx);
  if (curToken.is(FormatToken::string))
    return parseString(ctx);
  if (curToken.is(FormatToken::variable))
    return parseVariable(ctx);
  if (curToken.isKeyword())
    return parseDirective(ctx);
  if (curToken.is(FormatToken::l_paren))
    return parseOptionalGroup(ctx);
  return emitError(curToken.getLoc(),
                   "expected literal, variable, directive, or optional group");
}

FailureOr<FormatElement *> FormatParser::parseLiteral(Context ctx) {
  FormatToken tok = curToken;
  SMLoc loc = tok.getLoc();
  consumeToken();

  if (ctx != TopLevelContext) {
    return emitError(
        loc,
        "literals may only be used in the top-level section of the format");
  }
  // Get the spelling without the surrounding backticks.
  StringRef value = tok.getSpelling();
  // Prevents things like `$arg0` or empty literals (when a literal is expected
  // but not found) from getting segmentation faults.
  if (value.size() < 2 || value[0] != '`' || value[value.size() - 1] != '`')
    return emitError(tok.getLoc(), "expected literal, but got '" + value + "'");
  value = value.drop_front().drop_back();

  // The parsed literal is a space element (`` or ` `) or a newline.
  if (value.empty() || value == " " || value == "\\n")
    return create<WhitespaceElement>(value);

  // Check that the parsed literal is valid.
  if (!isValidLiteral(value, [&](Twine msg) {
        (void)emitError(loc, "expected valid literal but got '" + value +
                                 "': " + msg);
      }))
    return failure();
  return create<LiteralElement>(value);
}

FailureOr<FormatElement *> FormatParser::parseString(Context ctx) {
  FormatToken tok = curToken;
  SMLoc loc = tok.getLoc();
  consumeToken();

  if (ctx != CustomDirectiveContext) {
    return emitError(
        loc, "strings may only be used as 'custom' directive arguments");
  }
  // Escape the string.
  std::string value;
  StringRef contents = tok.getSpelling().drop_front().drop_back();
  value.reserve(contents.size());
  bool escape = false;
  for (char c : contents) {
    escape = c == '\\';
    if (!escape)
      value.push_back(c);
  }
  return create<StringElement>(std::move(value));
}

FailureOr<FormatElement *> FormatParser::parseVariable(Context ctx) {
  FormatToken tok = curToken;
  SMLoc loc = tok.getLoc();
  consumeToken();

  // Get the name of the variable without the leading `$`.
  StringRef name = tok.getSpelling().drop_front();
  return parseVariableImpl(loc, name, ctx);
}

FailureOr<FormatElement *> FormatParser::parseDirective(Context ctx) {
  FormatToken tok = curToken;
  SMLoc loc = tok.getLoc();
  consumeToken();

  if (tok.is(FormatToken::kw_custom))
    return parseCustomDirective(loc, ctx);
  if (tok.is(FormatToken::kw_ref))
    return parseRefDirective(loc, ctx);
  if (tok.is(FormatToken::kw_qualified))
    return parseQualifiedDirective(loc, ctx);
  return parseDirectiveImpl(loc, tok.getKind(), ctx);
}

FailureOr<FormatElement *> FormatParser::parseOptionalGroup(Context ctx) {
  SMLoc loc = curToken.getLoc();
  consumeToken();
  if (ctx != TopLevelContext) {
    return emitError(loc,
                     "optional groups can only be used as top-level elements");
  }

  // Parse the child elements for this optional group.
  std::vector<FormatElement *> thenElements, elseElements;
  FormatElement *anchor = nullptr;
  auto parseChildElements =
      [this, &anchor](std::vector<FormatElement *> &elements) -> LogicalResult {
    do {
      FailureOr<FormatElement *> element = parseElement(TopLevelContext);
      if (failed(element))
        return failure();
      // Check for an anchor.
      if (curToken.is(FormatToken::caret)) {
        if (anchor) {
          return emitError(curToken.getLoc(),
                           "only one element can be marked as the anchor of an "
                           "optional group");
        }
        anchor = *element;
        consumeToken();
      }
      elements.push_back(*element);
    } while (!curToken.is(FormatToken::r_paren));
    return success();
  };

  // Parse the 'then' elements. If the anchor was found in this group, then the
  // optional is not inverted.
  if (failed(parseChildElements(thenElements)))
    return failure();
  consumeToken();
  bool inverted = !anchor;

  // Parse the `else` elements of this optional group.
  if (curToken.is(FormatToken::colon)) {
    consumeToken();
    if (failed(parseToken(
            FormatToken::l_paren,
            "expected '(' to start else branch of optional group")) ||
        failed(parseChildElements(elseElements)))
      return failure();
    consumeToken();
  }
  if (failed(parseToken(FormatToken::question,
                        "expected '?' after optional group")))
    return failure();

  // The optional group is required to have an anchor.
  if (!anchor)
    return emitError(loc, "optional group has no anchor element");

  // Verify the child elements.
  if (failed(verifyOptionalGroupElements(loc, thenElements, anchor)) ||
      failed(verifyOptionalGroupElements(loc, elseElements, nullptr)))
    return failure();

  // Get the first parsable element. It must be an element that can be
  // optionally-parsed.
  auto isWhitespace = [](FormatElement *element) {
    return isa<WhitespaceElement>(element);
  };
  auto thenParseBegin = llvm::find_if_not(thenElements, isWhitespace);
  auto elseParseBegin = llvm::find_if_not(elseElements, isWhitespace);
  unsigned thenParseStart = std::distance(thenElements.begin(), thenParseBegin);
  unsigned elseParseStart = std::distance(elseElements.begin(), elseParseBegin);

  if (!isa<LiteralElement, VariableElement, CustomDirective>(*thenParseBegin)) {
    return emitError(loc, "first parsable element of an optional group must be "
                          "a literal, variable, or custom directive");
  }
  return create<OptionalElement>(std::move(thenElements),
                                 std::move(elseElements), thenParseStart,
                                 elseParseStart, anchor, inverted);
}

FailureOr<FormatElement *> FormatParser::parseCustomDirective(SMLoc loc,
                                                              Context ctx) {
  if (ctx != TopLevelContext && ctx != StructDirectiveContext) {
    return emitError(loc, "`custom` can only be used at the top-level context "
                          "or within a `struct` directive");
  }

  FailureOr<FormatToken> nameTok;
  if (failed(parseToken(FormatToken::less,
                        "expected '<' before custom directive name")) ||
      failed(nameTok =
                 parseToken(FormatToken::identifier,
                            "expected custom directive name identifier")) ||
      failed(parseToken(FormatToken::greater,
                        "expected '>' after custom directive name")) ||
      failed(parseToken(FormatToken::l_paren,
                        "expected '(' before custom directive parameters")))
    return failure();

  // Parse the arguments.
  std::vector<FormatElement *> arguments;
  while (true) {
    FailureOr<FormatElement *> argument = parseElement(CustomDirectiveContext);
    if (failed(argument))
      return failure();
    arguments.push_back(*argument);
    if (!curToken.is(FormatToken::comma))
      break;
    consumeToken();
  }

  if (failed(parseToken(FormatToken::r_paren,
                        "expected ')' after custom directive parameters")))
    return failure();

  if (failed(verifyCustomDirectiveArguments(loc, arguments)))
    return failure();
  return create<CustomDirective>(nameTok->getSpelling(), std::move(arguments));
}

FailureOr<FormatElement *> FormatParser::parseRefDirective(SMLoc loc,
                                                           Context context) {
  if (context != CustomDirectiveContext)
    return emitError(loc, "'ref' is only valid within a `custom` directive");

  FailureOr<FormatElement *> arg;
  if (failed(parseToken(FormatToken::l_paren,
                        "expected '(' before argument list")) ||
      failed(arg = parseElement(RefDirectiveContext)) ||
      failed(
          parseToken(FormatToken::r_paren, "expected ')' after argument list")))
    return failure();

  return create<RefDirective>(*arg);
}

FailureOr<FormatElement *> FormatParser::parseQualifiedDirective(SMLoc loc,
                                                                 Context ctx) {
  if (failed(parseToken(FormatToken::l_paren,
                        "expected '(' before argument list")))
    return failure();
  FailureOr<FormatElement *> var = parseElement(ctx);
  if (failed(var))
    return var;
  if (failed(markQualified(loc, *var)))
    return failure();
  if (failed(
          parseToken(FormatToken::r_paren, "expected ')' after argument list")))
    return failure();
  return var;
}

//===----------------------------------------------------------------------===//
// Utility Functions
//===----------------------------------------------------------------------===//

bool mlir::tblgen::shouldEmitSpaceBefore(StringRef value,
                                         bool lastWasPunctuation) {
  if (value.size() != 1 && value != "->")
    return true;
  if (lastWasPunctuation)
    return !StringRef(">)}],").contains(value.front());
  return !StringRef("<>(){}[],").contains(value.front());
}

bool mlir::tblgen::canFormatStringAsKeyword(
    StringRef value, function_ref<void(Twine)> emitError) {
  if (value.empty()) {
    if (emitError)
      emitError("keywords cannot be empty");
    return false;
  }
  if (!isalpha(value.front()) && value.front() != '_') {
    if (emitError)
      emitError("valid keyword starts with a letter or '_'");
    return false;
  }
  if (!llvm::all_of(value.drop_front(), [](char c) {
        return isalnum(c) || c == '_' || c == '$' || c == '.';
      })) {
    if (emitError)
      emitError(
          "keywords should contain only alphanum, '_', '$', or '.' characters");
    return false;
  }
  return true;
}

bool mlir::tblgen::isValidLiteral(StringRef value,
                                  function_ref<void(Twine)> emitError) {
  if (value.empty()) {
    if (emitError)
      emitError("literal can't be empty");
    return false;
  }
  char front = value.front();

  // If there is only one character, this must either be punctuation or a
  // single character bare identifier.
  if (value.size() == 1) {
    StringRef bare = "_:,=<>()[]{}?+*";
    if (isalpha(front) || bare.contains(front))
      return true;
    if (emitError)
      emitError("single character literal must be a letter or one of '" + bare +
                "'");
    return false;
  }
  // Check the punctuation that are larger than a single character.
  if (value == "->")
    return true;
  if (value == "...")
    return true;

  // Otherwise, this must be an identifier.
  return canFormatStringAsKeyword(value, emitError);
}

//===----------------------------------------------------------------------===//
// Commandline Options
//===----------------------------------------------------------------------===//

llvm::cl::opt<bool> mlir::tblgen::formatErrorIsFatal(
    "asmformat-error-is-fatal",
    llvm::cl::desc("Emit a fatal error if format parsing fails"),
    llvm::cl::init(true));
