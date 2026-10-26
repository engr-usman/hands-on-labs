# AWS-02 · Live guestbook app on Amazon EC2

| Level | Time | Cost | Services |
|---|---|---|---|
| 🟢 Beginner | 20 min | Free Tier eligible (`t3.micro`); terminate after use | Amazon EC2, Security Groups |

## 🎯 What you’ll build

A real Linux server on AWS running a small **Python Flask** app. Visitors sign a guestbook with their name and a one-line message, and the list updates live every 3 seconds. The page also shows the **instance ID, Availability Zone and instance type**, read from EC2 instance metadata.

The whole server is set up automatically by one **user-data** script on first boot.

```
📱 Browser ──HTTP :80──▶ [ Security group: 80 open, 22 my IP ] ──▶ 🖥️ EC2 t3.micro · Amazon Linux 2023 · Flask
```

## ✅ Prerequisites

- An AWS account ([Getting started](../../../getting-started/README.md))

## 📂 Files

| File | What it does |
|---|---|
| `user-data.sh` | Installs Python and Flask, writes the app, and runs it as a `systemd` service on port 80 |

---

## Steps (EC2 console)

1. Open `user-data.sh` and change `RESET_CODE` near the top.
2. **EC2 → Launch instance.** Name: `acm-guestbook`.
3. **AMI:** Amazon Linux 2023 · **Instance type:** `t3.micro`.
4. **Key pair:** create one (only needed if you want to SSH in).
5. **Network settings → Edit**, keep *Auto-assign public IP* **enabled**, and add these security group rules:
   - SSH · TCP 22 · Source: **My IP**
   - HTTP · TCP 80 · Source: **Anywhere (0.0.0.0/0)**
6. **Advanced details → User data:** paste the **entire** `user-data.sh`.
7. **Launch instance.** Wait about **2 minutes**, copy the **Public IPv4 address** and open `http://<public-ip>` (use `http`, not `https`).

## 🔍 Verify

- The page shows your instance ID and Availability Zone.
- Sign the guestbook from two devices; both lists update within a few seconds.

## 🧰 Handy extras

| What | How |
|---|---|
| Clear all entries | `http://<public-ip>/reset?code=<your RESET_CODE>` |
| Health check | `http://<public-ip>/health` → `ok` |
| Watch logs live | SSH in → `sudo journalctl -u guestbook -f` |
| See what user data did | SSH in → `sudo cat /var/log/cloud-init-output.log` |
| Restart the app | `sudo systemctl restart guestbook` |

## 🧹 Clean up

**EC2 → Instances → select `acm-guestbook` → Instance state → Terminate.**
Then delete the key pair and security group if you no longer need them.

> Stopped ≠ deleted. A stopped instance still pays for its disk. **Terminate** it.

## 🛠️ Troubleshooting

| Problem | Fix |
|---|---|
| Page never loads | The security group needs HTTP 80 from `0.0.0.0/0`. Check the URL starts with `http://`. |
| Still nothing after 5 minutes | SSH in and read `/var/log/cloud-init-output.log` for `dnf` or `pip` errors. |
| Campus Wi-Fi blocks it | Try mobile data or a phone hotspot. |

## 🚀 Challenges

1. Store entries in **Amazon DynamoDB** instead of SQLite.
2. Run two instances behind an **Application Load Balancer** with an **Auto Scaling group**.
3. Rebuild the whole lab with **Terraform** or **AWS CloudFormation**.
