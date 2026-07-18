import PyInstaller.__main__
import os
import sys

def build_exe():
    """Build Windows executable using PyInstaller"""
    
    print("🚀 Building DARK CART executable...")
    print("=" * 50)
    
    PyInstaller.__main__.run([
        'game.py',
        '--name=DARK_CART',
        '--onefile',
        '--windowed',
        '--icon=BUILT_BY_COPILOT.ico' if os.path.exists('BUILT_BY_COPILOT.ico') else None,
        '--add-data=.,.',
        '--hidden-import=pygame',
        '--clean',
        '--distpath=./build/dist',
        '--buildpath=./build/build',
        '--specpath=./build',
    ])
    
    print("=" * 50)
    print("✅ Build complete!")
    print("📦 Executable location: ./build/dist/DARK_CART.exe")
    print("🎮 Run the game with: ./build/dist/DARK_CART.exe")

if __name__ == "__main__":
    try:
        build_exe()
    except Exception as e:
        print(f"❌ Error during build: {e}")
        print("\nMake sure PyInstaller is installed:")
        print("pip install pyinstaller")
        sys.exit(1)
