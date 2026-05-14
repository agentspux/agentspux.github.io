# How to Set Up Cline in VS Code (Salesforce Proxy + Anthropic Key)

Welcome! 👋 This guide walks you through setting up **Cline** (an AI coding assistant) inside **Visual Studio Code (VS Code)** and connecting it to **Claude** through a **local Salesforce proxy** using your **Anthropic key**.

You **don't need any coding experience** to follow this guide. Just go step by step. The whole setup takes about **15 minutes**.

> 🔐 **How this works (in plain English):**
> Instead of talking to Anthropic directly, Cline will send messages to a small program running on **your own computer** (called a "proxy") at the address `http://127.0.0.1:9999`. That proxy then forwards your messages to Claude through Salesforce's secure gateway, using your Anthropic key.
>
> You don't need to understand the details — just follow the steps. ✅

---

## 📋 Before You Start — What You'll Need

Make sure you have all of the following ready:

- ✅ A Mac computer (this guide is written for macOS)
- ✅ An internet connection
- ✅ Your **Anthropic key** (a string that looks like `sk-ant-...` or similar)
- ✅ The **proxy folder** from your team, placed at: `~/sf-bedrock-proxy/`
  - Inside it, there should be a file called `proxy.js`
  - If you don't have this folder, ask your team lead for it before continuing.

> 💡 **What is `~`?** It's a shortcut that means "your home folder" — for example, `/Users/yourname/`.

---

## ⚡ Quick Install (One Command)

If you'd rather not do the manual steps, you can run a single command in **Terminal** that does everything in this guide for you (installs VS Code, Cline, sets up the proxy, and asks for your Anthropic key):

```bash
curl -fsSL https://raw.githubusercontent.com/<your-username>/<your-repo>/main/scripts/install-cline.sh | bash
```

> 📝 Replace `<your-username>/<your-repo>` with the actual GitHub path where this script is hosted.

The script will:
- ✅ Check you're on macOS
- ✅ Install Homebrew, Node.js, and VS Code (if missing)
- ✅ Install the Cline extension
- ✅ Verify `~/sf-bedrock-proxy/proxy.js` exists
- ✅ Prompt for your Anthropic key (input hidden)
- ✅ Add an auto-start block to `~/.zshrc`
- ✅ Start the proxy and print the exact Cline settings to use

After it finishes, just follow **Step 5 (Connect Cline to the Proxy)** below to plug in the settings inside VS Code, and you're done.

> If you prefer to do it manually (or the script fails), keep reading — the rest of this guide walks through every step by hand. 👇

---

## 🪜 Step 1: Install Visual Studio Code (VS Code)


VS Code is a free code editor made by Microsoft. We'll install Cline inside of it.

1. Open your web browser and go to: **https://code.visualstudio.com/**
2. Click the big blue **Download for Mac** button.
3. Once the download finishes, **open the `.zip` file** in your **Downloads** folder.
4. Drag the **Visual Studio Code** icon into your **Applications** folder.
5. Open **Applications**, then double-click **Visual Studio Code** to launch it.
   - If macOS asks "Are you sure you want to open it?" — click **Open**.

> ✅ You'll know it worked when you see the VS Code welcome screen.

---

## 🧩 Step 2: Install the Cline Extension

Extensions add new features to VS Code. Cline is one of them.

1. Open **VS Code** if it's not already open.
2. On the **left-hand sidebar**, click the icon that looks like **four squares** (one is detached). This is the **Extensions** button.
   - Or press: `Cmd + Shift + X`
3. In the search bar at the top, type:

   ```
   Cline
   ```

4. Find the extension named **"Cline"** (it has a robot-style icon, published by **Cline**).
5. Click the blue **Install** button.
6. Wait a few seconds. When the button changes to **"Uninstall"** or **"Disable"**, you're done. ✅

---


## ⚙️ Step 3: Set Up the Salesforce Proxy on Your Computer

The proxy is what lets Cline talk to Claude using your Anthropic key. We'll set it up once, and after that it can start automatically.

### 3a. Confirm the proxy file exists

1. Open the **Terminal** app on your Mac.
   - Press `Cmd + Space`, type `Terminal`, and press **Enter**.
2. In the Terminal window, copy and paste this command, then press **Enter**:

   ```bash
   ls ~/sf-bedrock-proxy/proxy.js
   ```

3. ✅ If you see something like `/Users/yourname/sf-bedrock-proxy/proxy.js`, you're good.
   ❌ If you see `No such file or directory`, stop here and ask your team for the `sf-bedrock-proxy` folder.

### 3b. Make sure Node.js is installed

The proxy is a small Node.js program, so we need Node installed.

1. In Terminal, run:

   ```bash
   node --version
   ```

2. If you see something like `v18.0.0` or higher → ✅ you're set, skip to Step 3c.
3. If you see `command not found`, install Node by running:

   ```bash
   brew install node
   ```

   - If `brew` is also not found, install Homebrew first by following: **https://brew.sh/**
   - Then re-run `brew install node`.

### 3c. Add the auto-start script to your shell

This step makes the proxy start **automatically** every time you open Terminal, so you never have to think about it again.

1. In Terminal, open your shell config file in a simple editor:

   ```bash
   open -e ~/.zshrc
   ```

   (A TextEdit window will open. If the file is empty, that's fine.)

2. **Scroll to the bottom** of the file and **paste in** the following block exactly:

   ```bash
   # --- SF Bedrock Proxy for Cline ---

   # Start the proxy ONLY if it isn't already running on :9999.
   sf_bedrock_proxy_start() {
     if lsof -nP -iTCP:9999 -sTCP:LISTEN >/dev/null 2>&1; then
       return 0  # already running
     fi
     if [[ ! -f "$HOME/sf-bedrock-proxy/proxy.js" ]]; then
       return 0  # nothing to start
     fi
     ANTHROPIC_AUTH_TOKEN="sk-key" \
       nohup node "$HOME/sf-bedrock-proxy/proxy.js" \
         >/tmp/sf-bedrock-proxy.log 2>&1 &
     disown 2>/dev/null
   }

   # Auto-start the proxy on shell load (silent, idempotent).
   sf_bedrock_proxy_start

   # Manual command to open VS Code with the Cline profile.
   cline-vscode() {
     sf_bedrock_proxy_start
     AWS_REGION="us-east-1" code --profile "Cline" "$@"
   }

   # Convenience: stop the proxy
   sf_bedrock_proxy_stop() {
     pkill -f "$HOME/sf-bedrock-proxy/proxy.js" && echo "Proxy stopped." || echo "Proxy not running."
   }
   ```

3. **🔑 IMPORTANT — Replace the key:**
   Find this line in what you just pasted:

   ```bash
   ANTHROPIC_AUTH_TOKEN="sk-key" \
   ```

   Replace `sk-key` with **your actual Anthropic key**. For example:

   ```bash
   ANTHROPIC_AUTH_TOKEN="sk-ant-api03-XXXXXXXXXXXXXXXXXXX" \
   ```

   > ⚠️ Keep the **double quotes** around the key. Don't share this file with anyone.

4. **Save the file:** Press `Cmd + S`, then close the TextEdit window.

---

## ▶️ Step 4: Start the Proxy

Now let's load your new settings and start the proxy.

1. In Terminal, run:

   ```bash
   source ~/.zshrc
   ```

   This loads the script you just saved. The proxy should start silently in the background.

2. **Verify the proxy is running** by running:

   ```bash
   lsof -nP -iTCP:9999 -sTCP:LISTEN
   ```

3. ✅ If you see a line mentioning `node` and port `9999`, the proxy is running!
   ❌ If you see nothing, check the log for errors:

   ```bash
   cat /tmp/sf-bedrock-proxy.log
   ```

> 💡 From now on, the proxy will start **automatically** every time you open Terminal. You usually won't have to think about it.

---


## 🔗 Step 5: Connect Cline to the Proxy

Now we'll tell Cline to send its requests to the proxy on your computer instead of straight to Anthropic.

1. Open **VS Code**.
   - 💡 *Tip:* You can open VS Code from Terminal using the helper command we set up:
     ```bash
     cline-vscode
     ```
     This guarantees the proxy is running before VS Code opens.
2. On the **left-hand sidebar**, click the **Cline icon** (looks like a robot/chat bubble).
   - If you don't see it, close VS Code and reopen it.
3. The Cline panel will open. Click the **⚙️ settings (gear) icon** at the top of the Cline panel.
4. In the settings, fill in the fields exactly as follows:

   | Field | Value |
   |---|---|
   | **API Provider** | `Anthropic` |
   | **Anthropic API Key** | `sk-key` *(any non-empty value works — the real key lives in the proxy)* |
   | **Use custom base URL** | ✅ **Check this box** |
   | **Base URL** | `http://127.0.0.1:9999` |
   | **Model** | Pick the latest **Claude Sonnet** option (e.g., `claude-sonnet-4`) |

   > 🧠 **Why a fake key?** Cline requires *something* in the API Key field, but your real Anthropic key is already inside the proxy script. The proxy will swap in the real key automatically.

5. Click **Save** (or **Done**) at the bottom of the settings panel.

✅ Cline is now connected to Claude through your local proxy!

---

## 💬 Step 6: Test That It Works

Let's send a test message.

1. In the Cline chat box at the bottom of the panel, type:

   ```
   Hello! Please reply with a single sentence so I know you're working.
   ```

2. Press **Enter** (or click the **Send** arrow).
3. Within a few seconds, you should see a reply from Claude.

🎉 **You're all set!** Cline is now connected and ready to help you.

---

## 🛠️ Troubleshooting — Common Issues

| Problem | What to try |
|---|---|
| **Cline says "connection refused" or "ECONNREFUSED 127.0.0.1:9999"** | The proxy isn't running. In Terminal, run `source ~/.zshrc`, then check with `lsof -nP -iTCP:9999 -sTCP:LISTEN`. |
| **Cline says "401 Unauthorized" or "invalid token"** | Your Anthropic key in `~/.zshrc` is wrong. Open `~/.zshrc`, fix the value of `ANTHROPIC_AUTH_TOKEN`, save, and run `sf_bedrock_proxy_stop` then `sf_bedrock_proxy_start`. |
| **Cline icon doesn't appear** | Quit VS Code completely (`Cmd + Q`) and reopen it. |
| **"command not found: node"** | Install Node with `brew install node`. |
| **Proxy log shows errors** | View the log: `cat /tmp/sf-bedrock-proxy.log`. Share it with your team if you can't tell what's wrong. |
| **I changed my key but Cline still fails** | Restart the proxy: `sf_bedrock_proxy_stop` then `sf_bedrock_proxy_start`. |
| **I want to stop the proxy** | Run `sf_bedrock_proxy_stop` in Terminal. |

---

## 🔁 Daily Usage — What to Do Each Day

Once everything is set up, your daily flow is simple:

1. **Open Terminal** → the proxy starts automatically (silently).
2. **Open VS Code** (either normally, or by running `cline-vscode` in Terminal).
3. **Click the Cline icon** and start chatting. ✅

That's it!

---

## 🔑 How to Update Your Anthropic Key Later

If your Anthropic key changes:

1. In Terminal, run:
   ```bash
   open -e ~/.zshrc
   ```
2. Find the line:
   ```bash
   ANTHROPIC_AUTH_TOKEN="..."
   ```
3. Replace the value inside the quotes with your new key.
4. Save the file (`Cmd + S`) and close TextEdit.
5. Restart the proxy:
   ```bash
   sf_bedrock_proxy_stop
   source ~/.zshrc
   ```

Done! ✅

---

## 🎓 Summary — You've Successfully:

- ✅ Installed **VS Code**
- ✅ Installed the **Cline extension**
- ✅ Set up the **Salesforce proxy** with your **Anthropic key**
- ✅ Configured Cline to use the proxy at `http://127.0.0.1:9999`
- ✅ Sent your first message to Claude

Happy building! 🚀

> 📚 If you get stuck, the official Cline docs are at: **https://docs.cline.bot/**

