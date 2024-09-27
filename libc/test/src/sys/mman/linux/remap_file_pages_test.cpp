//===-- Unittests for remap_file_pages ------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "src/errno/libc_errno.h"
#include "src/sys/mman/mmap.h"
#include "src/sys/mman/munmap.h"
#include "src/sys/mman/remap_file_pages.h"
#include "src/unistd/sysconf.h"
#include "test/UnitTest/ErrnoSetterMatcher.h"
#include "test/UnitTest/Test.h"

#include <sys/mman.h>

using LIBC_NAMESPACE::testing::ErrnoSetterMatcher::Fails;
using LIBC_NAMESPACE::testing::ErrnoSetterMatcher::Succeeds;

TEST(LlvmLibcRemapFilePagesTest, NoError) {
  size_t page_size = sysconf(_SC_PAGE_SIZE);
  ASSERT_GT(page_size, size_t(0));

  // First, allocate some memory using mmap
  size_t alloc_size = 2 * page_size;
  LIBC_NAMESPACE::libc_errno = 0;
  void *addr = LIBC_NAMESPACE::mmap(nullptr, alloc_size, PROT_READ | PROT_WRITE,
                                    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  ASSERT_ERRNO_SUCCESS();
  EXPECT_NE(addr, MAP_FAILED);

  // Reset error number for the new function
  LIBC_NAMESPACE::libc_errno = 0;

  // Now try to remap the pages
  EXPECT_THAT(LIBC_NAMESPACE::remap_file_pages(addr, page_size, PROT_READ,
                                               page_size, 0),
              Succeeds());

  // Reset error number for the new function
  LIBC_NAMESPACE::libc_errno = 0;

  // Clean up
  EXPECT_THAT(LIBC_NAMESPACE::munmap(addr, alloc_size), Succeeds());
}

TEST(LlvmLibcRemapFilePagesTest, ErrorInvalidFlags) {
  size_t page_size = sysconf(_SC_PAGESIZE);
  ASSERT_GT(page_size, size_t(0));

  void *addr = LIBC_NAMESPACE::mmap(nullptr, page_size, PROT_READ | PROT_WRITE,
                                    MAP_PRIVATE | MAP_ANONYMOUS, -1, 0);
  ASSERT_NE(addr, MAP_FAILED);

  // Try to remap pages with an invalid flag MAP_PRIVATE
  EXPECT_THAT(LIBC_NAMESPACE::remap_file_pages(addr, page_size, PROT_READ, 0,
                                               MAP_PRIVATE),
              Fails(EINVAL));

  // Clean up
  EXPECT_THAT(LIBC_NAMESPACE::munmap(addr, page_size), Succeeds());
}

TEST(LlvmLibcRemapFilePagesTest, ErrorInvalidAddress) {
  size_t page_size = sysconf(_SC_PAGESIZE);
  ASSERT_GT(page_size, size_t(0));

  // Use an address that we haven't mapped
  void *invalid_addr = reinterpret_cast<void *>(0x12345000);

  EXPECT_THAT(LIBC_NAMESPACE::remap_file_pages(invalid_addr, page_size,
                                               PROT_READ, 0, 0),
              Fails(EINVAL));
}
