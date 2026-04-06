# Keylone User Guide

**Keylone** is a self-hosted password manager with zero-knowledge architecture.
The server stores only encrypted data and never has access to your passwords.

---

## 🔐 Login & Registration

### Registration
Enter your email and choose a **master password**. The master password is the only way to decrypt your vault. The server never knows or stores it. **Remember it or write it down in a safe place.**

> 💡 Use a long passphrase of several words — easy to remember and hard to crack.

### Login
Keylone supports two login methods:

- **Email + password** — enter your email and master password. If two-factor authentication (TOTP) is enabled, a 6-digit code from your authenticator app will be required.
- **Passkey** — sign in with biometrics or a hardware key (Face ID, Touch ID, YubiKey). Replaces email+password+TOTP entirely. After passkey confirmation, only the master password is needed to decrypt the vault.

### Forgot your password?
Click *"Forgot password?"* on the login page. A reset link will be sent to your email or Telegram (if connected). Follow the link and enter a new password.

> ⚠️ If you don't have a recovery key, vault data will become inaccessible. Be sure to create a recovery key in advance.

---

## 🗄️ Vault

### Item types

| Type | Stores |
|------|--------|
| 🔑 Login | Website, username, password, TOTP secret, notes |
| 📝 Note | Encrypted freeform text |
| 💳 Card | Card number, holder, expiry |
| 🔒 SSH Key | Public and private SSH keys |

### Adding an item
Click the **"+ Add"** button in the top-right corner. If you're in a folder, it will be auto-assigned. Fill in the fields and save.

### Editing and deleting
Click an item to view it. In the details panel on the right — *"Edit"* and *"Delete"* buttons. Press `Esc` to close the panel.

### Search
Type in the search box at the top. Search works across name, username, URL, and notes in real time.

### Copying
In the item list, 📋 buttons next to the username and password copy data to the clipboard. The password is hidden until you click 👁.

### Breach check
In the item details, the *"Check breaches"* button sends an anonymous password hash to HaveIBeenPwned and reports whether the password has been compromised.

---

## 📁 Folders

### Creating a folder
In the left panel, click the **"+"** button next to the "Folders" section. Enter a name and save.

### Nested folders
When creating a folder, you can choose a parent folder. Unlimited nesting is supported. Click the arrow next to a folder to expand subfolders.

### Moving items
Drag an item from the list to a folder in the left panel. Or open the item editor and change the "Folder" field.

### Renaming and deleting
Click the pencil icon next to a folder. When deleting a folder, items inside are not deleted — they move to "No Folder".

---

## 🎲 Password Generator

The **"Generator"** tab creates cryptographically random passwords, passphrases, and PINs.

### 🔐 Password
- **Length** — 8 to 128 characters (16+ recommended)
- **Character sets** — uppercase (A-Z), lowercase (a-z), digits (0-9), special characters (!@#…)

### 💬 Passphrase
Several random words joined by a separator: `Maple-River-Cloud-Horn-Dawn`. Easy to remember, hard to crack.
- **Word count** — 3–10 (5–6 recommended, ~50–60 bits of entropy)
- **Separator** — hyphen, dot, underscore, space, or slash
- **Capitalize** — first letter of each word capitalized
- **Add number** — a 3-digit random number appended at the end

### 🔢 PIN
- **Length** — 4–12 characters
- **Digits only (0-9)** or **Hex (0-9, A-F)**

The entropy indicator is shown below the output — the higher, the harder to crack.

> 💡 A quick password generator is also available directly in the add/edit item form — the 🎲 button next to the password field.

---

## 🗝️ Recovery Key

> ⚠️ The recovery key is a critical security element. Create it immediately after registration.

### What it is
The recovery key is a long random string like `XXXXXXXX-XXXXXXXX-...` — a backup way to decrypt your vault if you forget the master password or an admin resets your password.

### How to create
1. Go to **Settings → Account → Recovery Key**
2. Click *"Create recovery key"*
3. Copy or download the key — it's shown only once
4. Store the key safely (print it, write it down, or save it in another password manager)

### One-time use
After use, the key is automatically revoked. Create a new one in Settings — Keylone will remind you.

### When you need it
- You reset your password via email/Telegram — the key is needed to decrypt the vault
- An admin forcibly reset your password
- You logged in on a new device after changing your password

---

## 🛡️ Two-Factor Authentication & Passkeys

### TOTP — second factor for password login
TOTP strengthens the standard login (email + password): after entering the password, a 6-digit code from your authenticator app is required.

1. Install an app: Google Authenticator, Authy, 2FAS, or any TOTP-compatible app
2. Go to **Settings → Security → Two-Factor Authentication**
3. Click *"Set up TOTP"* — scan the QR code with your app
4. Enter the code from the app to confirm

### Passkeys — alternative login method
A passkey **replaces** email + password + TOTP entirely. It's not an additional factor but a separate authentication method:
- Sign in with biometrics or a hardware key (Face ID, Touch ID, YubiKey, Windows Hello)
- After passkey confirmation, only the master password is entered — to decrypt the vault on your device
- You can use either a passkey or email+password(+TOTP) — your choice

1. Go to **Settings → Security → Passkeys**
2. Click *"Add passkey"* and follow the browser instructions
3. Give the key a name for convenience

Multiple passkeys can be added (for different devices).

---

## 🔄 Change Master Password

1. Go to **Settings → Account → Change Password**
2. Enter your current password, new password, and confirmation
3. Click *"Change password"*

After changing your password, all sessions will end and you'll need to log in again.

> 💡 The vault is automatically re-encrypted with the new key — your data remains accessible.

---

## 📎 Attachments

Files can be attached to any item (documents, screenshots, keys). Files are encrypted before being sent to the server.

### Upload
Open an item → *"Attachments"* tab in the details panel → *"Attach file"* button. Maximum file size is **10 MB**.

### Download
In the attachments list, click the file name — the file will be decrypted and downloaded.

### Delete
Click 🗑️ next to the attachment.

---

## 📤 Export & Import

### Export
Go to **Settings → Data → Export**. Data is exported as JSON. To protect the file, enter a password — the exported file will be encrypted.

> ⚠️ The exported file contains all your passwords in plain text (unless password-protected). Keep it in a safe place.

### Import
Go to **Settings → Data → Import**. Supported formats:
- **Keylone JSON** — native format (encrypted or plain)
- **CSV** — universal format (username, password, URL, note)

### Clear vault
Under **Settings → Data**, you can permanently delete all items and folders. This action is irreversible.

---

## ✈️ Telegram Notifications

Keylone can send notifications and password reset links via Telegram.

### Connect personal account
1. Go to **Settings → Account → Telegram**
2. Send the `/start` command to the bot — the bot will show your Chat ID
3. Paste the Chat ID into the field and save

After connecting, the admin can send you password reset links via Telegram, and (if notifications are enabled) you'll receive login notifications.

### Where to find Chat ID
Send `/start` or `/chatid` to the bot. The bot will reply with your Chat ID — a number like `123456789`.

---

## 🧩 Browser Extensions

Extensions are available for Chrome, Firefox, and Safari. Download them from the **"Downloads"** tab.

### Chrome installation
1. Download the `.zip` extension file
2. Unzip to a folder
3. Open `chrome://extensions` → enable *"Developer mode"*
4. Click *"Load unpacked extension"* and select the folder

### Firefox installation
1. Download the `.xpi` file
2. In Firefox: *Add-ons → gear icon → Install from file*
3. Select the downloaded `.xpi`

### Extension features
- Autofill login and password on websites
- Offer to save password on login
- Search vault from popup
- Generate passwords directly in the browser

### First launch
Click the extension icon → enter your Keylone server address → sign in with your credentials.

---

## 🔒 Security Architecture

### Zero-knowledge encryption
Keylone uses a zero-knowledge architecture: the server never sees your passwords or data in plain text.

### How encryption works
1. **Master key** — derived from master password and email via Argon2id (slow hash)
2. **Encryption key** — derived from master key via HKDF
3. **Vault key** — random AES-256 key, encrypted with the encryption key
4. **Data** — each item is encrypted with the vault key (AES-256-GCM)

The server stores only the encrypted vault key and encrypted items.

### What the server cannot do
- Read your passwords
- Reset the master password without your knowledge (only via email/Telegram)
- Decrypt the vault without the master password or recovery key

### Session locking
The vault key is stored in the tab's memory and browser session storage. On browser close or timeout — the vault locks and the key is deleted.

---

## 👑 Admin Panel

> This section is only available to administrators. The **"Administration"** tab appears in the left menu.

### Users tab
- **Create user** — create an account for a new team member
- **Reset password** — send a reset link via email or Telegram (recommended)
- **Admin rights** — grant or revoke administrator privileges
- **Disable TOTP** — if the user has lost access to their authenticator

### Settings tab
- **Registration** — open or close self-registration
- **Password history** — number of recent passwords that cannot be reused (0 = disabled)

### Notifications tab
Configure the SMTP server for email and Telegram bot for notifications. The *"Test email"* and *"Test Telegram"* buttons let you verify the channels.

---

## 💡 Tips & Keyboard Shortcuts

### Keyboard shortcuts

| Key | Action |
|-----|--------|
| `Esc` | Close details panel / form |
| `Ctrl+F` / `⌘F` | Focus search box |

### Tips
- Use folders for organization: by project, category, or access level
- Add TOTP secrets to items — Keylone will show the one-time code directly in the vault
- Regularly check passwords for breaches using the "Check breaches" button
- After using the recovery key, create a new one immediately
- Regularly export a backup of your vault
