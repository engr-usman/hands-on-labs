# ☁️ Cloud DevOps Labs

Hands-on **AWS, DevOps and AI labs** from my talks, bootcamps and trainings.
Every lab has a step-by-step guide, ready-to-run code and cleanup steps, so you can follow along during a session or practise on your own afterwards.

**Maintained by [Syed Usman Ahmad](https://syedusmanahmad.com)** · Head of DevOps · AWS Community Builder · AWS Certified Solutions Architect – Professional · CKA

---

## 🚀 New here? Start with these 3 steps

1. Read **[Getting started](getting-started/README.md)**: create an AWS account safely (MFA + budget alert).
2. Pick your session from the **[Sessions](#-sessions)** table below.
3. Open the labs listed for that session and follow the README step by step.

---

## 🎤 Sessions

Newest first. Each session folder has the agenda, slides and the labs we used.

| Date | Session | Host | Labs |
|---|---|---|---|
| 27 Oct 2026 | [Cloud Computing on AWS](sessions/2026-10-27-superior-university-cloud-computing-on-aws/README.md) | Superior ACM Society, Superior University | AWS-01, AWS-02 |
| 25 Oct 2026 | [From Servers to Self-Healing (AWS, DevOps & AIOps)](sessions/2026-10-25-from-servers-to-self-healing/README.md) | [Event name] | [add labs] |

---

## 🧪 Labs

Labs are reusable. The same lab can appear in many sessions.

### AWS

| ID | Lab | Level | Time | Services | Server? |
|---|---|---|---|---|---|
| AWS-01 | [Static website on Amazon S3](labs/aws/01-s3-static-website/README.md) | 🟢 Beginner | 15 min | S3 | No |
| AWS-02 | [Live guestbook app on Amazon EC2](labs/aws/02-ec2-flask-guestbook/README.md) | 🟢 Beginner | 20 min | EC2, Security Groups | Yes |

### DevOps · Kubernetes · AIOps

Coming in future sessions. ⭐ **Star** or 👁️ **Watch** this repo to get notified.

**Level guide:** 🟢 Beginner · 🟡 Intermediate · 🔴 Advanced

---

## 📁 Repository structure

```
cloud-devops-labs/
├── getting-started/      # One-time setup: AWS account, MFA, budget, CLI
├── labs/                 # Reusable hands-on labs, grouped by topic
│   ├── aws/
│   ├── devops/
│   ├── kubernetes/
│   └── aiops/
├── sessions/             # One folder per talk: agenda, slides, links to labs
│   └── YYYY-MM-DD-host-topic/
└── templates/            # Template for writing a new lab
```

---

## ⚠️ Golden rules

- **Clean up after every lab.** Each lab has a cleanup section. Forgotten resources become real bills.
- **Never commit AWS access keys** to GitHub. Bots find them within minutes.
- These labs are for **learning**. Some shortcuts (like public buckets) are not production practice; each README explains the production way.

---

## 🙌 Found a bug or have a question?

Open an [issue](../../issues) or message me on LinkedIn: **[your-profile]**.
If a lab helped you, tag me when you post your result. I love seeing what you build.

## 📄 License

[MIT](LICENSE) — free to use, share and adapt, with credit.
