-- Migration: Add granular stage tracking for applications and referrals
-- This allows referrers to see every individual stage their referred friend completes

-- ============================================
-- 1. Add 'stage' column to applications table
-- ============================================
DO $$
BEGIN
  -- Check if applications table exists first
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'applications'
  ) THEN
    -- Add stage column if it doesn't exist
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'applications'
      AND column_name = 'stage'
    ) THEN
      ALTER TABLE public.applications
      ADD COLUMN stage text NOT NULL DEFAULT 'invited';

      -- Add constraint separately to avoid issues
      ALTER TABLE public.applications
      ADD CONSTRAINT applications_stage_check
      CHECK (stage IN (
        'invited',
        'application_started',
        'personal_info_submitted',
        'academic_info_submitted',
        'documents_submitted',
        'application_fee_paid',
        'application_submitted'
      ));
    END IF;
  ELSE
    RAISE NOTICE 'Applications table does not exist. Please run required_tables.sql first.';
  END IF;
END $$;

-- ============================================
-- 2. Add stage history tracking (JSONB array)
-- ============================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'applications'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'applications'
      AND column_name = 'stage_history'
    ) THEN
      ALTER TABLE public.applications
      ADD COLUMN stage_history jsonb DEFAULT '[]'::jsonb;
    END IF;
  END IF;
END $$;

-- ============================================
-- 3. Add stage timestamps for key milestones
-- ============================================
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_schema = 'public'
    AND table_name = 'applications'
  ) THEN
    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'applications'
      AND column_name = 'personal_info_submitted_at'
    ) THEN
      ALTER TABLE public.applications
      ADD COLUMN personal_info_submitted_at timestamptz;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'applications'
      AND column_name = 'academic_info_submitted_at'
    ) THEN
      ALTER TABLE public.applications
      ADD COLUMN academic_info_submitted_at timestamptz;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'applications'
      AND column_name = 'documents_submitted_at'
    ) THEN
      ALTER TABLE public.applications
      ADD COLUMN documents_submitted_at timestamptz;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'applications'
      AND column_name = 'application_fee_paid_at'
    ) THEN
      ALTER TABLE public.applications
      ADD COLUMN application_fee_paid_at timestamptz;
    END IF;

    IF NOT EXISTS (
      SELECT 1 FROM information_schema.columns
      WHERE table_schema = 'public'
      AND table_name = 'applications'
      AND column_name = 'application_submitted_at'
    ) THEN
      ALTER TABLE public.applications
      ADD COLUMN application_submitted_at timestamptz;
    END IF;
  END IF;
END $$;

-- ============================================
-- 4. Create function to auto-update stage history
-- ============================================
CREATE OR REPLACE FUNCTION update_application_stage_history()
RETURNS TRIGGER AS $$
BEGIN
  -- Only add to history if stage actually changed
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

-- ============================================
-- 5. Create trigger for stage history
-- ============================================
DROP TRIGGER IF EXISTS trg_update_application_stage_history ON public.applications;
CREATE TRIGGER trg_update_application_stage_history
  BEFORE UPDATE ON public.applications
  FOR EACH ROW
  EXECUTE FUNCTION update_application_stage_history();

-- ============================================
-- 6. Create index for faster stage queries
-- ============================================
CREATE INDEX IF NOT EXISTS idx_applications_stage ON public.applications (stage);
CREATE INDEX IF NOT EXISTS idx_referrals_application_stage ON public.referrals (application_stage);

-- ============================================
-- 7. Add comment for documentation
-- ============================================
COMMENT ON COLUMN public.applications.stage IS 'Current application stage: invited, application_started, personal_info_submitted, academic_info_submitted, documents_submitted, application_fee_paid, application_submitted';
COMMENT ON COLUMN public.applications.stage_history IS 'JSONB array tracking all stage transitions with timestamps';
COMMENT ON COLUMN public.referrals.application_stage IS 'Synced from applications.stage - shows referred user progress to referrer';

