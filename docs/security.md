# Security & privacy

This public case study is deliberately more restrictive than the historical development repository.

## Data removal

Before creating this portfolio version, the source snapshot was reviewed for:
- customer names;
- phone numbers;
- addresses;
- commercial pricing;
- client logos/branding;
- deployment-specific domains;
- credentials and environment configuration.

Published demo records are synthetic.

## Role enforcement

An early database version allowed any authenticated user to mutate several operational tables. That is too permissive for roles such as kitchen staff.

The representative hardening migration in `examples/rls-hardening.sql` changes the model so:
- authenticated users may read the operational data required by the application;
- only `admin` and `ventas` may mutate core operational records;
- `cocina` is effectively read-only;
- users cannot promote their own role through the public profile API;
- the signup trigger always assigns the safe default role `ventas`.

## Client-side configuration

Only public browser configuration should use `NEXT_PUBLIC_*` variables. Service-role keys or other privileged secrets must never be shipped to the browser or committed to source control.

## Production note

This portfolio repository does not contain production credentials and should not be treated as an export of the client's live environment.
