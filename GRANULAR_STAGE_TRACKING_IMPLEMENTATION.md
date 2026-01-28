# Granular Stage Tracking Implementation

## Overview
This implementation allows referrers to see **every individual stage** their referred friends complete in the application journey. Every time a user clicks "Save" on any part of the application, that specific stage is saved to the database and visible to both the referrer and the referred user.

## 7 Granular Stages

1. **Invited** - User received referral link
2. **Application Started** - User began filling application (any basic info entered)
3. **Personal Info Submitted** - User completed personal information section
4. **Academic Info Submitted** - User completed academic information section
5. **Documents Submitted** - User uploaded required documents
6. **Application Fee Paid** - User paid the application fee
7. **Application Submitted** - User submitted complete application

## Database Changes

### 1. Applications Table (`supabase/required_tables.sql`)
Added the following fields to the `applications` table:

```sql
-- Granular stage tracking
stage text NOT NULL DEFAULT 'invited' CHECK (stage IN (
  'invited',
  'application_started',
  'personal_info_submitted',
  'academic_info_submitted',
  'documents_submitted',
  'application_fee_paid',
  'application_submitted'
)),
stage_history jsonb DEFAULT '[]'::jsonb,

-- Stage timestamps
personal_info_submitted_at timestamptz,
academic_info_submitted_at timestamptz,
documents_submitted_at timestamptz,
application_fee_paid_at timestamptz,
application_submitted_at timestamptz,
```

### 2. Auto-Update Stage History Trigger
Created a PostgreSQL function and trigger that automatically tracks stage changes:

```sql
CREATE OR REPLACE FUNCTION update_application_stage_history()
RETURNS TRIGGER AS $$
BEGIN
  IF OLD.stage IS DISTINCT FROM NEW.stage THEN
    NEW.stage_history = NEW.stage_history || jsonb_build_object(
      'stage', NEW.stage,
      'timestamp', NOW(),
      'previous_stage', OLD.stage
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 3. Migration File
Created `supabase/migrations/add_granular_stage_tracking.sql` to add these fields to existing databases.

## Code Changes

### 1. Application Model (`lib/models/application.dart`)
- Added `calculateCurrentStage()` method that automatically determines the current stage based on completed fields
- Enhanced `getApplicationStageString()` to map enum to database strings

### 2. Application Provider (`lib/providers/application_provider.dart`)
- Modified `updateApplication()` to automatically calculate and update stage on every save
- Added stage change detection to trigger referral sync
- Logs stage changes for debugging

### 3. Referral Tracker Widget (`lib/widgets/referral_tracker.dart`)
- Updated to show all 7 stages instead of 5
- Added horizontal scrolling for better mobile UX
- New stage labels: Invited → Started → Personal → Academic → Docs → Fee Paid → Submitted
- Added `_getStepIndex()` helper to map ApplicationStage enum to visual step index

### 4. Application Data Service (`lib/services/application_data_service.dart`)
- Updated to save `stage` field to database on create and update
- Uses `application.getApplicationStageString()` for proper mapping

## How It Works

### Automatic Stage Calculation
When a user saves any part of the application:

1. **ApplicationProvider.updateApplication()** is called
2. **Application.calculateCurrentStage()** analyzes what fields are filled:
   - If enrollment confirmed → `application_submitted`
   - If fee paid → `application_fee_paid`
   - If documents uploaded → `documents_submitted`
   - If academic info filled → `academic_info_submitted`
   - If personal info filled → `personal_info_submitted`
   - If any basic info → `application_started`
   - Otherwise → `invited`
3. Stage is updated in local storage and synced to Supabase
4. If stage changed, referral tracker is automatically synced
5. Database trigger logs the change to `stage_history`

### Referrer View
Referrers see the progress in the **Refer Screen → Referrals Tab** using the `ReferralTracker` widget:
- Visual progress bar with 7 steps
- Current stage highlighted in blue
- Completed stages shown in green with checkmarks
- Pending stages shown in gray

### Referred User View
Referred users see their own progress in the **Home Screen / Application Journey** using the `ApplicationStatusCard` widget:
- Status badge (Draft/In Progress/Submitted/etc.)
- Progress percentage bar
- Creation and submission dates

## Setup Instructions

### 1. Run Database Setup
Execute the SQL files in this order:

```bash
# First, create all required tables
psql -h <your-supabase-host> -U postgres -d postgres -f supabase/required_tables.sql

# Then, run the migration (if table already exists)
psql -h <your-supabase-host> -U postgres -d postgres -f supabase/migrations/add_granular_stage_tracking.sql
```

### 2. Test the Implementation
1. Create a referral link and send to a friend
2. Friend signs up and starts application
3. Friend fills personal info → Click Save
4. Check referrer's screen → Should show "Personal Info Submitted"
5. Friend fills academic info → Click Save
6. Check referrer's screen → Should show "Academic Info Submitted"
7. Continue through all stages

## Benefits

✅ **Real-time visibility** - Referrers see progress immediately after each save
✅ **Granular tracking** - All 7 stages visible, not just 5 major milestones
✅ **Automatic syncing** - No manual intervention needed
✅ **Stage history** - Complete audit trail of all stage changes
✅ **Timestamps** - Know exactly when each milestone was reached
✅ **Offline support** - Queued for sync if network fails

## Files Modified

1. `lib/models/application.dart` - Added stage calculation logic
2. `lib/providers/application_provider.dart` - Auto-calculate stage on save
3. `lib/widgets/referral_tracker.dart` - Show 7 stages instead of 5
4. `lib/services/application_data_service.dart` - Save stage to database
5. `supabase/required_tables.sql` - Added stage fields and triggers
6. `supabase/migrations/add_granular_stage_tracking.sql` - Migration for existing DBs

