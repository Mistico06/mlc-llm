//
//  logging.h
//  Minimal TVM logging replacement for MLCSwift
//

#ifndef TVM_RUNTIME_LOGGING_H_
#define TVM_RUNTIME_LOGGING_H_

#include <cassert>
#include <stdexcept>
#include <iostream>
#include <sstream>

// Basic logging levels
#define TVM_LOG_FATAL 0
#define TVM_LOG_ERROR 1
#define TVM_LOG_WARNING 2
#define TVM_LOG_INFO 3
#define TVM_LOG_DEBUG 4

// ICHECK macro - throws exception on failure
#define ICHECK(condition) \
  do { \
    if (!(condition)) { \
      std::ostringstream oss; \
      oss << "Check failed: " #condition \
          << " at " << __FILE__ << ":" << __LINE__; \
      throw std::runtime_error(oss.str()); \
    } \
  } while (0)

// ICHECK with custom message
#define ICHECK_MSG(condition, msg) \
  do { \
    if (!(condition)) { \
      std::ostringstream oss; \
      oss << "Check failed: " #condition << " " << msg \
          << " at " << __FILE__ << ":" << __LINE__; \
      throw std::runtime_error(oss.str()); \
    } \
  } while (0)

// Basic equality checks
#define ICHECK_EQ(a, b) ICHECK((a) == (b))
#define ICHECK_NE(a, b) ICHECK((a) != (b))
#define ICHECK_LT(a, b) ICHECK((a) < (b))
#define ICHECK_LE(a, b) ICHECK((a) <= (b))
#define ICHECK_GT(a, b) ICHECK((a) > (b))
#define ICHECK_GE(a, b) ICHECK((a) >= (b))

// Simple LOG macro for basic logging
#define LOG(level) \
  std::cerr << "[" #level "] " << __FILE__ << ":" << __LINE__ << " "

// VLOG for verbose logging (simplified)
#define VLOG(level) \
  if (level <= 1) std::cerr << "[VLOG" << level << "] "

// CHECK macros (same as ICHECK)
#define CHECK(condition) ICHECK(condition)
#define CHECK_EQ(a, b) ICHECK_EQ(a, b)
#define CHECK_NE(a, b) ICHECK_NE(a, b)
#define CHECK_LT(a, b) ICHECK_LT(a, b)
#define CHECK_LE(a, b) ICHECK_LE(a, b)
#define CHECK_GT(a, b) ICHECK_GT(a, b)
#define CHECK_GE(a, b) ICHECK_GE(a, b)

// DCHECK macros (debug checks - only active in debug builds)
#ifdef DEBUG
#define DCHECK(condition) ICHECK(condition)
#define DCHECK_EQ(a, b) ICHECK_EQ(a, b)
#define DCHECK_NE(a, b) ICHECK_NE(a, b)
#define DCHECK_LT(a, b) ICHECK_LT(a, b)
#define DCHECK_LE(a, b) ICHECK_LE(a, b)
#define DCHECK_GT(a, b) ICHECK_GT(a, b)
#define DCHECK_GE(a, b) ICHECK_GE(a, b)
#else
#define DCHECK(condition) ((void)0)
#define DCHECK_EQ(a, b) ((void)0)
#define DCHECK_NE(a, b) ((void)0)
#define DCHECK_LT(a, b) ((void)0)
#define DCHECK_LE(a, b) ((void)0)
#define DCHECK_GT(a, b) ((void)0)
#define DCHECK_GE(a, b) ((void)0)
#endif

#endif  // TVM_RUNTIME_LOGGING_H_
