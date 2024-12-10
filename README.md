This bash script automates the process of injecting a payload into an APK file. Here's a brief breakdown:

APK Selection: The user is prompted to provide the path of an APK file (either by dragging and dropping or manually entering it).
APK Decompilation: The APK is decompiled using apktool into a specified directory.
File Renaming: It renames any invalid resource files (containing $) in the drawable folder.
Payload Generation: The user provides the attacker's IP address and port. The script generates a Java-based payload that establishes a connection to the attacker's machine and sends/receives data.
Injection of Payload: The generated payload is injected into a specified activity within the APK, modifying the onCreate method.
Permissions Update: Necessary Android permissions (internet access and network state) are added to the AndroidManifest.xml.
APK Rebuilding: The modified APK is rebuilt with the injected payload and saved to a new file.
