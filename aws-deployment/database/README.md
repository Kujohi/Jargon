# Supabase ➜ Amazon RDS Migration

This folder contains everything required to copy **all existing data** from your Supabase project into the new Amazon RDS PostgreSQL instance provisioned by Terraform.

---
## 1. Install dependencies
```bash
cd aws-deployment/database
python3 -m venv .venv            # optional but recommended
source .venv/bin/activate
pip install -r requirements.txt
```

## 2. Export **Supabase** connection string & service-role key
Add them to a local `.env` file (see `.env.example`) **or** pass them on the CLI.

## 3. Ensure the RDS credentials secret exists in AWS Secrets Manager
Terraform creates the secret `jargon-ai/database/<env>` automatically and stores host / port / user / password. The script fetches this secret via the AWS SDK, so make sure your AWS credentials are loaded:
```bash
aws sso login   # or `aws configure`
```

## 4. Dry-run connectivity test (no data written)
```bash
python migrate_supabase_to_rds.py \
  --supabase-url $SUPABASE_DB_URL \
  --supabase-key $SUPABASE_SERVICE_KEY \
  --dry-run
```
You should see *"Connected to Supabase successfully"* and *"Connected to RDS successfully"*.

## 5. Perform the actual migration
```bash
python migrate_supabase_to_rds.py \
  --supabase-url $SUPABASE_DB_URL \
  --supabase-key $SUPABASE_SERVICE_KEY
```
The script will:
1. Connect to both databases
2. Create the required tables + indexes in RDS if they don’t exist
3. Upsert users → profiles → jars → transactions → savings_goals
4. Log progress & row counts for each stage

The process is **idempotent** – you can safely re-run it; existing rows are updated, not duplicated.

## 6. Validation
After the script finishes, validate row counts:
```sql
SELECT COUNT(*) FROM users;
SELECT COUNT(*) FROM jars;
SELECT COUNT(*) FROM transactions;
```
They should match the counts in Supabase.

---
### Environment variables
Name | Description | Example
---- | ----------- | -------
SUPABASE_URL | Supabase PostgreSQL connection string | `postgresql://postgres:password@db.supabase.com:5432/postgres`
SUPABASE_SERVICE_KEY | Supabase service role key | `eyJhbGci...`
RDS_SECRET_NAME | (optional) Secrets Manager name for the RDS JSON secret | `jargon-ai/database/dev`

You can either export them in your shell or place them inside an `.env` file (loaded via `python-dotenv`).

---
### Troubleshooting
* **`psycopg2.OperationalError`** – network connectivity/firewall issue. Ensure your local IP is allowed in the RDS SG or run from an EC2 instance inside the VPC.
* **`botocore.exceptions.ClientError: AccessDeniedException`** – the IAM principal you’re using lacks `secretsmanager:GetSecretValue` permissions.
* If the script stops midway, simply fix the underlying issue and re-run it; it will resume safely.