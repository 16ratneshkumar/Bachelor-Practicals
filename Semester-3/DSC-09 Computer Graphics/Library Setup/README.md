# How to Setup graphics.h for Visual Studio Code
## Introduction

- This article will guide you through the steps to set up graphical programming in Visual Studio Code using the Borland Graphics Interface (BGI) graphics.h library. This library is ideal for simple 2D graphics tasks like drawing lines, shapes, and basic animations.

- If you're looking to do modern graphical programming, you may want to consider newer libraries and frameworks such as DirectX, OpenGL, SDL, SFML, or Vulkan. These libraries provide more powerful, flexible, and modern tools for graphics programming.

---

### Introduction to graphics.h

- The graphics.h header file is a library for creating simple graphics in C/C++. It provides functions to draw shapes such as lines, rectangles, circles, and polygons. Additionally, it supports basic image manipulation and allows developers to draw on a graphical window.

- To use graphics.h, you will need to initialize the graphics driver using the *initgraph* function.


---

### What is Visual Studio Code?

- Visual Studio Code (VS Code) is a popular, lightweight source code editor developed by Microsoft. It supports various programming languages and offers features like debugging, syntax highlighting, intelligent code completion (IntelliSense), and more.

- You can download VS Code from [here]().


---

## Step-by-Step Instructions

   #### Step 1: Download Visual Studio Code

   1. Visit the Visual Studio Code website and [download]() the setup for your operating system (Windows, Linux, or macOS).


   2. Install it like any other software. After installation, open it and you’re ready to start coding!

---

   #### Step 2: Download and Install MinGW

   1. Visit the MinGW page and [download]() the latest version.


   2. Install MinGW by choosing the destination folder (for example, C:\MinGW).


   3. After installation, you will see the MinGW Installation Manager. In this, mark the following packages for installation:

        - mingw32-base

        - mingw32-gcc-g++

        - mysys-base



   4. Apply the changes and complete the installation.


---

   #### Step 3: Set Up the MinGW Path

   1. After MinGW installation, go to the MinGW/bin folder (e.g., C:\MinGW\bin) and copy the path from the address bar.


   2. **Open Control Panel -> System -> Advanced System Settings -> Environment Variables.**


   3. In System Variables, select Path, click Edit, then click New, and paste the path you copied.


   4. Click OK on all open windows to save the settings.



---

   #### Step 4: Verify MinGW Installation

   1. Open Command Prompt (press Win + R, type cmd, and hit Enter).


   2. Type the following command to check if GCC is installed correctly:
   ```sh
   gcc --version
   ```

   3. If it shows the GCC version, the setup is correct. If not, revisit the previous steps to ensure MinGW is installed properly.




---

   #### Step 5: Download the graphics.h Library

   1. Download the required files for setting up graphics.h from GitHub repository.
   ```sh
   git clone https://github.com/16ratneshkumar/Miscellaneous
   ```
   ```sh
   cd '.\Miscellaneous\Computer Graphics\Library Setup\Packages'
   ```

   2. Extract the downloaded file. It should contain:
        - graphics.h

        - winbgim.h

        - libbgi.a



   3. Copy the files: 
        - graphics.h and winbgim.h to the MinGW/include folder (e.g., C:\MinGW\include).

        - libbgi.a to the MinGW/lib folder (e.g., C:\MinGW\lib).


---

   #### Step 6: Configure VS code Project

   - To make things easier, Configure the vs code project template like this.
   ```plaintext
   📦 Miscellaneous
    ├── 📁 .vscode
    │   ├── c_cpp_properties.json
    │   ├── tasks.json
    └── 📁 Computer Graphics
        ├── 📁 build
        └── 📁 Practical
            └── Practical.cpp
   ```
   - The contant of **c_cpp_properties.json** & **tasks.json** is given below.
   - **c_cpp_properties.json**
```json
{
    "configurations": [
        {
            "name": "Win32",
            "includePath": [
                "${workspaceFolder}/**",
                "C:/MinGW/include"
            ],
            "defines": [
                "_DEBUG",
                "UNICODE",
                "_UNICODE"
            ],
            "compilerPath": "C:\\MinGW\\bin\\g++"
        }
    ],
    "version": 4
}
```
   - **tasks.json**
```json
{
    "version": "2.0.0",
    "tasks": [
      {
        "type": "process",
        "label": "C/C++: Build .exe",
        "command": "C:\\MinGW\\bin\\g++.exe",
        "args": ["-g",
                 "${file}",
                 "-o", 
                 "${workspaceFolder}\\Computer Graphics\\build\\${fileBasenameNoExtension}.exe",
                 "-lbgi",
                 "-lgdi32",
                 "-lcomdlg32",
                 "-luuid",
                 "-loleaut32",
                 "-lole32"
                ],
        "options": {
          "cwd": "${workspaceFolder}"
        },
        "problemMatcher": [],
        "group": {
          "kind": "build",
          "isDefault": true
        },
        "detail": "compiler: C:\\MinGW\\bin\\g++.exe"
      }
    ]
  }
```

   1. Extract the downloaded project template. It contains:

        - src/: Folder for source code files.

        - build/: Folder for compiled executable files.

        - .vscode/: Folder with settings for building and running your program.


---

   #### Step 7: Install Required Extensions in VS Code

   - To build and run programs using graphics.h, you need to install the following extensions in Visual Studio Code:

       1. C/C++ Extension: Search for "C/C++" by Microsoft in the extensions panel and install it.


       2. Code Runner Extension: Install "Code Runner" to easily run your programs inside VS Code.


       3. Exe Runner Extension: Search for and install "Exe Runner" to execute .exe files directly from VS Code.



   - After installing the extensions, restart Visual Studio Code.


---

   #### Step 8: Open and Build the Sample Project

   1. Go to the src folder in the project template and create the project.cpp file.


   2. Here's a simple code example to test the setup:
   ```cpp
   #include <graphics.h>
   #include <conio.h>

   int main() {
       int gd = DETECT, gm;
       initgraph(&gd, &gm, "");

       circle(300, 300, 100);  // Draw a circle
       getch();  // Wait for user input
       closegraph();  // Close the graphics window

       return 0;
   }
   ```

   3. To build and run the code:
   - Press Ctrl+Shift+B to run the build task.

   - After compiling, the executable .exe file will be saved in the build folder.

   - Right-click the .exe file in the build folder and select Run Executable to run the program.


---

   #### Step 9: Compile with Custom Code

   - You can create new C++ files in the src folder and follow the same steps to build and run them. Ensure that each time you compile, you use the required library linking flags for graphics.h:
   ```sh
   gcc filename.cpp -lbgi -lgdi32 -lcomdlg32 -luuid -loleaut32 -lole32 -o output.exe
   ```


---

## Conclusion

In this guide, we covered how to set up graphics.h in Visual Studio Code for basic graphical programming. While graphics.h is suitable for simple graphics, modern applications should use more advanced libraries like SDL, SFML, or OpenGL for better performance and flexibility.

If this guide was helpful, feel free to share it with your friends and peers!
