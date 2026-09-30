# Story 2.4: Stanley-Brown Safety Plan Screen & Interactive Accordions

Status: done

## Story Description
As a user in distress,
I want to view my personalised safety plan in 6 clean accordion cards with one-tap calling and texting,
So that I can follow my coping steps and reach my trusted contacts immediately without cognitive strain.

## Acceptance Criteria
1. Displays 6 Stanley-Brown steps as clear, low-stimulation accordion cards.
2. Contacts section displays name, phone, relationship, and professional badge.
3. Quick actions:
   - Tap Call launches `tel:<number>` via `url_launcher`.
   - Tap Text launches `sms:<number>?body=<encoded_template>` with pre-written compassionate template.
4. Dedicated crisis lines section pre-populated with standard crisis lines (e.g. 988 Suicide & Crisis Lifeline, Crisis Text Line 741741).
5. "Firefly supports — it does not replace professional care." persistent advisory footer.
6. Touch targets ≥ 56dp for emergency actions.
