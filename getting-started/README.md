# Getting started

Do this **once** before your first lab. It takes about 15 minutes.

## 1. Create an AWS account

Sign up at <https://aws.amazon.com/free>.
New accounts get up to **$200 in Free Tier credits**. The **Free plan** lasts up to 6 months or until the credits run out, and you are not charged unless you upgrade to the Paid plan.

## 2. Protect the account (do not skip)

| Step | Where |
|---|---|
| Turn on **MFA** for the root user | Top-right account menu → Security credentials → Assign MFA device |
| Create a **$5 budget alert** | Billing and Cost Management → Budgets → Create budget → *Zero spend* or *Monthly cost* template |
| Stop using root for daily work | IAM → Users → Create user (or use IAM Identity Center) and give it only the access you need |

## 3. (Optional) Install the AWS CLI

Some labs have a one-command CLI option.

- **Install:** <https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html>
- **Configure:** run `aws configure` and enter your access key, secret key and default region (e.g. `ap-south-1`).
- **Test:** `aws sts get-caller-identity` should print your account ID.

## 4. Pick a Region

Choose one Region and use it for every lab, so you can find (and delete) everything later.
Close to Pakistan: **Middle East (UAE) `me-central-1`**, **Middle East (Bahrain) `me-south-1`** or **Asia Pacific (Mumbai) `ap-south-1`**.

## 5. Get the code

```bash
git clone https://github.com/engr-usman/hands-on-labs.git
cd hands-on-labs
```

No Git? Click the green **Code** button on GitHub → **Download ZIP**.

✅ Done. Head back to the [main README](../README.md) and pick a lab.
