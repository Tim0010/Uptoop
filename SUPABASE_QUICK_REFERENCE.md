# ⚡ Supabase Quick Reference

## 🔑 Get Credentials (2 Minutes)

1. **Create Account:** https://supabase.com/
2. **Create Project:** Click "New Project"
3. **Get Credentials:**
   - Go to Settings → API
   - Copy **Project URL**
   - Copy **anon/public key**

## 📝 Update .env File

```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
```

## 🗄️ Set Up Database (3 Minutes)

1. Go to **SQL Editor** in Supabase
2. Click **"New query"**
3. Copy content from `supabase_schema.sql`
4. Paste and click **"Run"**
5. Done! ✅

## 🧪 Test

```bash
flutter pub get
flutter run
```

## 📊 View Data

1. Go to **Table Editor** in Supabase
2. Select **users** or **referrals** table
3. See your data in real-time!

## 🔍 Common Issues

| Issue | Solution |
|-------|----------|
| "Supabase not initialized" | Check .env file, run `flutter pub get` |
| "Failed to save" | Run SQL schema script |
| "Policy violation" | Re-run SQL schema script |
| Data not showing | Check Supabase dashboard logs |

## 📚 Files

- `supabase_schema.sql` - Database schema
- `lib/services/supabase_service.dart` - Service class
- `SUPABASE_SETUP_GUIDE.md` - Complete guide

## 🎯 What Gets Saved to Supabase?

### User Data (from onboarding):
- Phone number (verified)
- Full name
- Email address
- Age
- College/University
- Referral code (auto-generated)
- Referred by code (if applicable)

### Referral Data:
- Referrer information
- Referred person details
- Application status
- Reward tracking

### Session Data:
- Login timestamps
- Device information
- Session expiry

## 🚀 Features

✅ **Automatic Fallback** - Works without Supabase (offline mode)  
✅ **Real-time Sync** - Data syncs automatically  
✅ **Secure** - Row Level Security enabled  
✅ **Scalable** - Handles millions of users  
✅ **Free Tier** - 50,000 monthly active users  

## 💡 Pro Tips

1. **Backup Database:** Settings → Database → Backups
2. **Monitor Usage:** Settings → Usage
3. **View Logs:** Logs → Database
4. **API Docs:** Auto-generated at Settings → API
5. **Test Queries:** Use SQL Editor

## 🔗 Quick Links

- **Dashboard:** https://app.supabase.com/
- **Docs:** https://supabase.com/docs
- **Flutter Guide:** https://supabase.com/docs/reference/dart
- **Community:** https://github.com/supabase/supabase/discussions

---

**That's it!** You're ready to use Supabase with Uptop Careers! 🎉

