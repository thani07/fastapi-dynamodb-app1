# 📦 Create Your Deployment ZIP - Exact Files

## ✅ Files to INCLUDE in ZIP:

### Core Application Files:
```
📄 Dockerfile              ← Docker configuration
📄 Dockerrun.aws.json     ← Elastic Beanstalk config
📄 main.py                ← FastAPI entry point
📄 requirements.txt       ← Python dependencies
```

### Application Folders:
```
📁 api/
   ├── users.py
   └── __init__.py

📁 core/
   ├── config.py
   └── __init__.py

📁 db/
   ├── dynamodb.py
   └── __init__.py

📁 models/
   ├── user.py
   └── __init__.py

📁 services/
   ├── user_service.py
   └── __init__.py

📁 utils/
   └── __init__.py
```

---

## ❌ Files to EXCLUDE from ZIP:

```
❌ .env                     (Add credentials in AWS Console instead)
❌ .git/                    (Version control - not needed)
❌ __pycache__/             (Python cache)
❌ *.pyc                    (Compiled Python)
❌ *.md                     (Documentation)
❌ ReadMe.md
❌ DEPLOYMENT-*.md
❌ EASY-DEPLOYMENT.md
❌ ELASTIC-BEANSTALK-GUIDE.md
❌ NO-CLI-DEPLOYMENT.md
❌ docker-compose.yml       (Not needed for AWS)
❌ deploy-*.sh              (Scripts not needed)
❌ deploy-*.ps1
❌ deploy-*.bat
❌ ecs-task-definition*.json (ECS specific)
❌ iam-*.json               (Not needed)
❌ lambda_handler.py        (Lambda specific)
```

---

## 🪟 Windows - Step by Step:

### Method 1: File Explorer (Easiest)

1. **Open your `app` folder**

2. **Select ONLY these items** (Hold Ctrl and click):
   - Dockerfile
   - Dockerrun.aws.json
   - main.py
   - requirements.txt
   - api (folder)
   - core (folder)
   - db (folder)
   - models (folder)
   - services (folder)
   - utils (folder)

3. **Right-click on selected items** → **Send to** → **Compressed (zipped) folder**

4. **Name it**: `fastapi-app.zip`

5. **✅ Done!** Your ZIP is ready for upload

### Method 2: PowerShell (If you prefer)
```powershell
cd app

# Create ZIP with only required files
Compress-Archive -Path `
  Dockerfile, `
  Dockerrun.aws.json, `
  main.py, `
  requirements.txt, `
  api, `
  core, `
  db, `
  models, `
  services, `
  utils `
  -DestinationPath fastapi-app.zip -Force
```

---

## 🍎 Mac - Step by Step:

### Method 1: Finder (Easiest)

1. **Open your `app` folder** in Finder

2. **Select ONLY these items** (Hold ⌘ and click):
   - Dockerfile
   - Dockerrun.aws.json
   - main.py
   - requirements.txt
   - api (folder)
   - core (folder)
   - db (folder)
   - models (folder)
   - services (folder)
   - utils (folder)

3. **Right-click** → **Compress 10 Items**

4. **Rename** the archive to: `fastapi-app.zip`

5. **✅ Done!**

### Method 2: Terminal
```bash
cd app

zip -r fastapi-app.zip \
  Dockerfile \
  Dockerrun.aws.json \
  main.py \
  requirements.txt \
  api \
  core \
  db \
  models \
  services \
  utils
```

---

## 🐧 Linux - Terminal:

```bash
cd app

zip -r fastapi-app.zip \
  Dockerfile \
  Dockerrun.aws.json \
  main.py \
  requirements.txt \
  api \
  core \
  db \
  models \
  services \
  utils
```

---

## ✅ Verify Your ZIP:

### Windows:
1. Right-click `fastapi-app.zip`
2. Click "Open with" → "Windows Explorer" or "7-Zip"
3. Check you see:
   - ✅ Dockerfile
   - ✅ Dockerrun.aws.json
   - ✅ main.py
   - ✅ requirements.txt
   - ✅ api/ folder
   - ✅ core/ folder
   - ✅ db/ folder
   - ✅ models/ folder
   - ✅ services/ folder
   - ✅ utils/ folder

4. **Size**: Should be around 5-10 KB

### Mac/Linux:
```bash
unzip -l fastapi-app.zip
```

Should show all the files listed above.

---

## 🎯 Next Step:

**Now go to**: ELASTIC-BEANSTALK-GUIDE.md

Follow Step 2 to upload this ZIP to AWS!

---

## 📝 Quick Checklist:

- [ ] Created ZIP with correct files
- [ ] ZIP size is 5-10 KB
- [ ] Excluded .env file
- [ ] Excluded all .md files
- [ ] Included Dockerfile
- [ ] Included Dockerrun.aws.json
- [ ] Included all 6 folders (api, core, db, models, services, utils)
- [ ] Ready to upload to AWS!

**Your deployment package is ready! 🚀**
