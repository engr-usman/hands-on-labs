# AWS-01 · Static website on Amazon S3

| Level | Time | Cost | Services |
|---|---|---|---|
| 🟢 Beginner | 15 min | Cents per month (Free Tier eligible) | Amazon S3 |

## 🎯 What you’ll build

A real website, live on the internet, with **no server** to manage. The files sit in an S3 bucket and AWS serves them directly to the browser.

```
💻 Laptop  ──(upload / aws s3 sync)──▶  🪣 S3 bucket (website hosting ON)  ──(HTTP)──▶  📱 Browser
```

## ✅ Prerequisites

- An AWS account ([Getting started](../../../getting-started/README.md))
- *(CLI option only)* AWS CLI v2, configured with `aws configure`

## 📂 Files

| File | What it does |
|---|---|
| `site/index.html` | The home page, with a small interactive quiz |
| `site/style.css` | The styling |
| `site/error.html` | Custom 404 page |
| `deploy.sh` | Creates and publishes everything in one command |
| `make-public.sh` | Allows public **read-only** access to one bucket |
| `cleanup.sh` | Deletes the bucket and all its files |

---

## Option A · AWS Console (no code)

1. **S3 → Create bucket.** Use a globally unique, lowercase name, e.g. `acm-demo-yourname-2026`.
2. Open the bucket → **Properties → Static website hosting → Edit → Enable**.
   Index document: `index.html` · Error document: `error.html` → **Save**.
3. **Permissions → Block public access → Edit** → untick *Block all public access* → **Save** → type `confirm`.
4. **Permissions → Bucket policy → Edit**, paste this and replace `YOUR-BUCKET-NAME`:

   ```json
   {
     "Version": "2012-10-17",
     "Statement": [
       {
         "Sid": "PublicReadForStaticWebsite",
         "Effect": "Allow",
         "Principal": "*",
         "Action": "s3:GetObject",
         "Resource": "arn:aws:s3:::YOUR-BUCKET-NAME/*"
       }
     ]
   }
   ```

5. **Objects → Upload** the three files from the `site/` folder (the files, not the folder).
6. Go to **Properties → Static website hosting** and open the **Bucket website endpoint**. 🎉

## Option B · AWS CLI (one command)

```bash
cd labs/aws/01-s3-static-website
chmod +x *.sh
./deploy.sh acm-demo-yourname-2026 ap-south-1
```

The script prints your website URL at the end.

---

## 🔍 Verify

- The home page loads and the quiz buttons respond.
- Open `<your-url>/anything.html`: you should see the custom 404 page.

## 🧹 Clean up

```bash
./cleanup.sh acm-demo-yourname-2026
```

Or in the console: select the bucket → **Empty** → then **Delete**.

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| `403 Forbidden` | Block Public Access is still on (for the bucket **or** the whole account under *Block Public Access settings for this account*), or the bucket policy is missing. |
| `404` on the home page | `index.html` isn’t at the top level of the bucket. |
| `BucketAlreadyExists` | Bucket names are global. Add your name or a number. |
| The file downloads instead of displaying | You opened the object URL. Use the **website endpoint** (`s3-website`). |

## 🏭 In production

Keep the bucket **private** and serve it through **Amazon CloudFront** with Origin Access Control. You get HTTPS, caching and a custom domain.

## 🚀 Challenge

Replace the text in `site/index.html` with **your own portfolio** and share the link on LinkedIn.
