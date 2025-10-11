-- Indexes ----

---- 6.1 users & staff ----
CREATE INDEX k_user_status      ON USER(status_id);
CREATE INDEX k_user_last_login  ON USER(last_login_at);
CREATE INDEX k_staff_gym_status ON STAFF(gym_id, status_id);

---- 6.2 equipment ----
CREATE INDEX k_eitem_gym_kind   ON EQUIPMENT_ITEM(gym_id, equip_kind_id);
CREATE INDEX k_eitem_status     ON EQUIPMENT_ITEM(status_id);

---- 6.3 sessions & availability ----
CREATE INDEX k_csession_gym_starts ON CLASS_SESSION(gym_id, starts_at);
CREATE INDEX k_csession_state_open ON CLASS_SESSION(status_id, open_for_booking);
CREATE INDEX k_tavail_tr_date      ON TRAINER_AVAIL_DATE(trainer_id, for_date, period);

---- 6.4 bookings & checking in ----
CREATE INDEX k_booking_member_time ON BOOKING(member_id, booked_at);
CREATE INDEX k_booking_status      ON BOOKING(status_id);
CREATE INDEX k_checkin_member_time ON CHECK_IN(member_id, checked_in_at);
CREATE INDEX k_checkin_gym_time    ON CHECK_IN(gym_id, checked_in_at);