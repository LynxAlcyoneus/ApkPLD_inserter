# APK Payload Injection Script

This bash script automates the process of injecting a custom payload into an APK file. The steps involved are as follows:

## Steps

1. **APK Selection**
   - The user is prompted to provide the path of an APK file (either by dragging and dropping or manually entering it).

2. **APK Decompilation**
   - The APK is decompiled using `apktool` into a specified directory.

3. **File Renaming**
   - Invalid resource files (containing `$`) in the drawable folder are renamed for compatibility.

4. **Payload Generation**
   - The user provides the attacker's IP address and port. The script generates a Java-based payload that establishes a connection to the attacker's machine and sends/receives data.

5. **Injection of Payload**
   - The generated payload is injected into a specified activity within the APK, modifying the `onCreate` method.

6. **Permissions Update**
   - Necessary Android permissions (e.g., internet access and network state) are added to the `AndroidManifest.xml`.

7. **APK Rebuilding**
   - The modified APK is rebuilt with the injected payload and saved to a new file.
   
## Usage

1. Clone the repository or download the script to your local machine.
   
2. Install `apktool` if you don’t have it:
   ```bash
   sudo apt install apktool
   ```bash
   chmod +x inject_payload.sh
   ```bash
   ./inject_payload.sh
