# 🧪 Authentication Testing Plan - Phase 1

## Test Instructions

Follow these tests exactly and report results back to me:

---

### TEST 1: Registration Auto-Login Test
**What to test**: Does registration automatically log you in?

**Steps**:
1. Open the app
2. Click "Register" button
3. Fill in:
   - Full Name: `Test User`
   - Email: `test@example.com`
   - Phone: `0501234567`
   - Password: `Password123`
   - Confirm Password: `Password123`
4. Click "Register"
5. **OBSERVE**:
   - ✅ Expected: Directly see home/products screen (auto-logged in)
   - ❌ Problem: Redirected to login screen (NOT auto-logged in)

**Report Back**:
```
TEST 1 RESULT:
- [ ] Auto-logged in ✅ (expected)
- [ ] Redirected to login ❌ (problem)
- Error message shown: _______________
```

---

### TEST 2: Login & Logout Cycle Test
**What to test**: Can you login and logout properly?

**Steps**:
1. Complete TEST 1 first (or manually login if it failed)
2. Navigate to profile/settings screen
3. Click "Logout"
4. **OBSERVE** 1 - Loading:
   - Does it show loading spinner?
   - How long does logout take?
5. **OBSERVE** 2 - After logout:
   - Are you on login screen?
   - Try to access a protected route (products, favorites) - redirected?
6. **OBSERVE** 3 - Check storage:
   - Are you really logged out or just UI showing login?

**Report Back**:
```
TEST 2 RESULT:
- Logout time: ___ seconds
- Redirected to login: [ ] Yes  [ ] No
- Protected routes blocked: [ ] Yes  [ ] No
- Storage cleared: [ ] Yes  [ ] No  [ ] Unknown

Error message (if any): _______________
```

---

### TEST 3: Expired Token Test
**What to test**: How does app behave with invalid/expired token?

**Steps**:
1. Login successfully
2. Open browser DevTools or use terminal to modify GetStorage
   ```bash
   # Access GetStorage file and corrupt the token:
   # Location varies by platform - look in app cache directory
   ```
   OR: Manually clear the token from GetStorage and app will treat it as expired
3. Try to access protected screen (products, store)
4. **OBSERVE**:
   - ✅ Expected: Error message + redirect to login
   - ❌ Problem: App crashes or freezes
   - ⚠️ Issue: Silent redirect without message

**Report Back**:
```
TEST 3 RESULT:
- App behavior: [ ] Error shown  [ ] Silent redirect  [ ] Crash  [ ] Freeze
- Error message: _______________
- Redirected to login: [ ] Yes  [ ] No  [ ] Maybe
```

---

### TEST 4: Network Error Test
**What to test**: How does login handle no internet?

**Steps**:
1. Close app completely
2. Disable internet (airplane mode ON or WiFi+Mobile off)
3. Open app
4. Try to login
5. **OBSERVE**:
   - What message appears?
   - How long until it shows?
   - Can user retry?

**Report Back**:
```
TEST 4 RESULT:
- Error message shown: [ ] Yes  [ ] No
- Message text: _______________
- Can user retry: [ ] Yes  [ ] No
```

---

### TEST 5: Social Login Test (if implemented)
**What to test**: Does Google login work?

**Steps**:
1. On login screen, click "Login with Google"
2. **OBSERVE**:
   - [ ] Google popup appears
   - [ ] Error message
   - [ ] Nothing happens
   - [ ] Feature not visible

**Report Back**:
```
TEST 5 RESULT:
- Status: [ ] Works  [ ] Doesn't work  [ ] Not implemented
- Error (if any): _______________
```

---

### TEST 6: Multiple Login Attempts
**What to test**: Does rate limiting work?

**Steps**:
1. Try to login with wrong password 5 times
2. Try 6th attempt
3. **OBSERVE**:
   - Is 6th attempt blocked?
   - What message appears?
   - After 15 minutes, can you try again?

**Report Back**:
```
TEST 6 RESULT:
- Blocked after 5 attempts: [ ] Yes  [ ] No
- Message text: _______________
- Lockout duration: ___ minutes
```

---

## 📝 Summary Format

After completing all tests, provide this summary:

```
═══════════════════════════════════════════════════
          AUTHENTICATION TEST RESULTS
═══════════════════════════════════════════════════

TEST 1 (Registration): [ ] PASS  [ ] FAIL
TEST 2 (Logout): [ ] PASS  [ ] FAIL  
TEST 3 (Expired Token): [ ] PASS  [ ] FAIL
TEST 4 (Network Error): [ ] PASS  [ ] FAIL
TEST 5 (Social Login): [ ] PASS  [ ] FAIL  [ ] N/A
TEST 6 (Rate Limiting): [ ] PASS  [ ] FAIL

CRITICAL ISSUES FOUND:
1. _______________
2. _______________

HIGH ISSUES FOUND:
1. _______________

OTHER OBSERVATIONS:
_______________

═══════════════════════════════════════════════════
```

---

## ⏰ Expected Timeline

- TEST 1: 2 minutes
- TEST 2: 3 minutes
- TEST 3: 5 minutes
- TEST 4: 5 minutes
- TEST 5: 2 minutes (or N/A)
- TEST 6: 5 minutes

**Total: ~20 minutes**

---

## 🎯 What I'm Looking For

| Finding | Means |
|---------|-------|
| Registration doesn't auto-login | Issue #1 CONFIRMED |
| Logout takes 0-1 second | No API call being made (Issue #2) |
| Token error shows on expired | Good practice |
| Network error well-handled | Good practice |
| Social login fails/N/A | Issue #7 |
| Rate limiting works | Good practice |

---

**Once you complete testing**, reply with your results in the summary format above, and I'll provide exact code fixes for Phase 2! ✨

No coding needed for Phase 1 - just testing and reporting! 🎯
