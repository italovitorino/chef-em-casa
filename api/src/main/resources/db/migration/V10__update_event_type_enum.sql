-- V10__update_event_type_enum.sql
-- Migrates existing records from old EventType values to new ones.
-- Old: PRIVATE_DINNER, LUNCH, CORPORATE_EVENT, TRAVEL, OTHER
-- New: ROMANTIC_DINNER, BIRTHDAY, SOCIAL_GATHERING, BUSINESS_DINNER,
--      INTIMATE_WEDDING, FAMILY_REUNION, WINE_TASTING, BRUNCH, PREMIUM_BBQ, OTHER
UPDATE briefings.briefings SET event_type = 'ROMANTIC_DINNER'  WHERE event_type = 'PRIVATE_DINNER';
UPDATE briefings.briefings SET event_type = 'SOCIAL_GATHERING' WHERE event_type = 'CORPORATE_EVENT';
UPDATE briefings.briefings SET event_type = 'OTHER'            WHERE event_type = 'TRAVEL';
UPDATE briefings.briefings SET event_type = 'OTHER'            WHERE event_type = 'LUNCH';
