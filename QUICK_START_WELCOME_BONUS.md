# Quick Start: Testing Welcome Bonus

## 🎉 Welcome Bonus Feature is Ready!

Every new user now receives **₹10** with a celebration animation after signing up.

## 🚀 Quick Test (2 Options)

### Option 1: Test with New Account (See Full Experience)

1. **Logout** from current account
2. **Use a NEW phone number** (not +919253664013)
3. Complete OTP verification
4. Fill onboarding form (name, age, email, college)
5. Click "Create Account"
6. **See the magic!** 🎊
   - Confetti animation
   - ₹10 bonus celebration
   - Automatic wallet credit

### Option 2: Add Bonus to Timothy's Account (Quick Test)

**Copy and paste this into Supabase SQL Editor:**

```sql
-- Add ₹10 welcome bonus to Timothy Chibinda
INSERT INTO public.transactions (user_id, type, amount, status, description, completed_at)
VALUES ('341cc69d-dfc9-4864-a368-b37feb4f74fd', 'bonus', 10.00, 'completed', 'Welcome Bonus! 🎉', NOW());

UPDATE public.users
SET total_earnings = COALESCE(total_earnings, 0) + 10.00
WHERE id = '341cc69d-dfc9-4864-a368-b37feb4f74fd';
```

**Then:**
1. Restart the app
2. Go to **Wallet** tab
3. See ₹10 in your balance! 💰

## ✅ What to Check

After adding the bonus:
- [ ] Wallet shows ₹10 total balance
- [ ] Transaction list shows "Welcome Bonus! 🎉"
- [ ] Filter by "Bonus" to see the transaction
- [ ] Status is "Completed"

## 📝 Important Notes

- **Timothy Chibinda is an existing user**, so he won't get the bonus automatically
- The welcome bonus is **only for NEW users** during onboarding
- Each user can only receive the bonus **once** (duplicate prevention built-in)
- To see the celebration animation, you must create a **new account**

## 🎯 Recommendation

**For the best testing experience:**
1. Use Option 2 to quickly verify the wallet integration works
2. Then use Option 1 to see the full celebration experience with a new account

## 📚 More Details

See these files for complete documentation:
- `WELCOME_BONUS_IMPLEMENTATION.md` - Full technical details
- `TESTING_WELCOME_BONUS.md` - Comprehensive testing guide
- `supabase/add_bonus_timothy.sql` - Ready-to-use SQL script

## 🐛 Troubleshooting

**Bonus not showing after SQL?**
- Restart the app or pull to refresh

**Want to test again?**
- Delete the bonus transaction and try again (see TESTING_WELCOME_BONUS.md)

**Want to see the celebration dialog?**
- Must create a new account with a different phone number

---

**Ready to test?** Choose your option above and enjoy the ₹10 bonus! 🎉

