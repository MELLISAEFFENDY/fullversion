#!/usr/bin/env python3
"""
AutoFish Pro - Advanced Auto Update Script
Provides GUI and CLI options for automatic repository updates
"""

import os
import sys
import subprocess
import tkinter as tk
from tkinter import messagebox, scrolledtext, ttk
from datetime import datetime
import threading
import argparse

class AutoUpdater:
    def __init__(self):
        self.repo_path = os.getcwd()
        self.is_git_repo = os.path.exists(os.path.join(self.repo_path, '.git'))
        
    def run_command(self, command, capture_output=True):
        """Run a shell command and return result"""
        try:
            if capture_output:
                result = subprocess.run(command, shell=True, capture_output=True, text=True, cwd=self.repo_path)
                return result.returncode == 0, result.stdout.strip(), result.stderr.strip()
            else:
                result = subprocess.run(command, shell=True, cwd=self.repo_path)
                return result.returncode == 0, "", ""
        except Exception as e:
            return False, "", str(e)
    
    def check_git_status(self):
        """Check if there are any changes in the repository"""
        if not self.is_git_repo:
            return False, "Not a git repository"
        
        success, output, error = self.run_command("git status --porcelain")
        if not success:
            return False, f"Git status failed: {error}"
        
        return len(output.strip()) > 0, output
    
    def get_changed_files(self):
        """Get list of changed files"""
        success, output, _ = self.run_command("git status --short")
        if success and output:
            return output.split('\n')
        return []
    
    def stage_changes(self):
        """Stage all changes"""
        return self.run_command("git add .")
    
    def commit_changes(self, message):
        """Commit staged changes"""
        return self.run_command(f'git commit -m "{message}"')
    
    def push_changes(self, force=False):
        """Push changes to remote repository"""
        command = "git push origin main"
        if force:
            command += " --force"
        return self.run_command(command)
    
    def get_remote_url(self):
        """Get remote repository URL"""
        success, output, _ = self.run_command("git remote get-url origin")
        return output if success else "Unknown"
    
    def generate_commit_message(self, custom_message=None):
        """Generate automatic commit message"""
        if custom_message:
            return custom_message
        
        timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        changed_files = self.get_changed_files()
        
        if not changed_files:
            return f"🔄 Auto-update: General improvements - {timestamp}"
        
        # Analyze file types
        lua_files = [f for f in changed_files if '.lua' in f]
        md_files = [f for f in changed_files if '.md' in f]
        script_files = [f for f in changed_files if any(ext in f for ext in ['.ps1', '.bat', '.py'])]
        
        changes = []
        if lua_files:
            changes.append(f"Updated {len(lua_files)} Lua modules")
        if md_files:
            changes.append(f"Updated {len(md_files)} documentation files")
        if script_files:
            changes.append(f"Updated {len(script_files)} scripts")
        
        if changes:
            return f"🔄 Auto-update: {', '.join(changes)} - {timestamp}"
        else:
            return f"🔄 Auto-update: {len(changed_files)} files modified - {timestamp}"

class AutoUpdaterGUI:
    def __init__(self):
        self.updater = AutoUpdater()
        self.root = tk.Tk()
        self.setup_gui()
        
    def setup_gui(self):
        """Setup the GUI interface"""
        self.root.title("AutoFish Pro - Auto Update Tool")
        self.root.geometry("600x500")
        self.root.resizable(True, True)
        
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Title
        title_label = ttk.Label(main_frame, text="🚀 AutoFish Pro - Auto Update Tool", 
                              font=("Arial", 16, "bold"))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 20))
        
        # Status frame
        status_frame = ttk.LabelFrame(main_frame, text="Repository Status", padding="10")
        status_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # Repository info
        self.repo_label = ttk.Label(status_frame, text=f"Repository: {self.updater.repo_path}")
        self.repo_label.grid(row=0, column=0, sticky=tk.W)
        
        self.remote_label = ttk.Label(status_frame, text=f"Remote: {self.updater.get_remote_url()}")
        self.remote_label.grid(row=1, column=0, sticky=tk.W)
        
        self.status_label = ttk.Label(status_frame, text="Checking status...")
        self.status_label.grid(row=2, column=0, sticky=tk.W)
        
        # Check status button
        check_button = ttk.Button(status_frame, text="🔄 Check Status", command=self.check_status)
        check_button.grid(row=3, column=0, pady=(10, 0))
        
        # Commit message frame
        commit_frame = ttk.LabelFrame(main_frame, text="Commit Message", padding="10")
        commit_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        self.message_var = tk.StringVar()
        self.message_entry = ttk.Entry(commit_frame, textvariable=self.message_var, width=60)
        self.message_entry.grid(row=0, column=0, sticky=(tk.W, tk.E), padx=(0, 10))
        
        auto_message_button = ttk.Button(commit_frame, text="Auto Generate", 
                                       command=self.generate_message)
        auto_message_button.grid(row=0, column=1)
        
        # Options frame
        options_frame = ttk.LabelFrame(main_frame, text="Options", padding="10")
        options_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        self.force_var = tk.BooleanVar()
        force_check = ttk.Checkbutton(options_frame, text="Force push (⚠️ Use with caution)", 
                                    variable=self.force_var)
        force_check.grid(row=0, column=0, sticky=tk.W)
        
        # Action buttons
        button_frame = ttk.Frame(main_frame)
        button_frame.grid(row=4, column=0, columnspan=2, pady=(0, 10))
        
        self.update_button = ttk.Button(button_frame, text="🚀 Update Repository", 
                                      command=self.start_update, state="disabled")
        self.update_button.grid(row=0, column=0, padx=(0, 10))
        
        preview_button = ttk.Button(button_frame, text="👁️ Preview Changes", 
                                  command=self.preview_changes)
        preview_button.grid(row=0, column=1)
        
        # Progress bar
        self.progress = ttk.Progressbar(main_frame, mode='indeterminate')
        self.progress.grid(row=5, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        # Log output
        log_frame = ttk.LabelFrame(main_frame, text="Output Log", padding="10")
        log_frame.grid(row=6, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        self.log_text = scrolledtext.ScrolledText(log_frame, height=10, width=70)
        self.log_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(1, weight=1)
        main_frame.rowconfigure(6, weight=1)
        status_frame.columnconfigure(0, weight=1)
        commit_frame.columnconfigure(0, weight=1)
        log_frame.columnconfigure(0, weight=1)
        log_frame.rowconfigure(0, weight=1)
        
        # Initial status check
        self.root.after(100, self.check_status)
    
    def log(self, message):
        """Add message to log"""
        timestamp = datetime.now().strftime("%H:%M:%S")
        self.log_text.insert(tk.END, f"[{timestamp}] {message}\n")
        self.log_text.see(tk.END)
        self.root.update()
    
    def check_status(self):
        """Check repository status"""
        if not self.updater.is_git_repo:
            self.status_label.config(text="❌ Not a git repository")
            self.update_button.config(state="disabled")
            return
        
        has_changes, output = self.updater.check_git_status()
        
        if has_changes:
            changed_files = self.updater.get_changed_files()
            self.status_label.config(text=f"✅ {len(changed_files)} files changed")
            self.update_button.config(state="normal")
            self.log(f"Found {len(changed_files)} changed files")
        else:
            self.status_label.config(text="✅ Repository is up to date")
            self.update_button.config(state="disabled")
            self.log("No changes detected")
    
    def generate_message(self):
        """Generate automatic commit message"""
        message = self.updater.generate_commit_message()
        self.message_var.set(message)
        self.log(f"Generated commit message: {message}")
    
    def preview_changes(self):
        """Preview changes before committing"""
        success, output, error = self.updater.run_command("git diff --stat")
        if success and output:
            self.log("Changed files preview:")
            self.log(output)
        
        changed_files = self.updater.get_changed_files()
        if changed_files:
            self.log("File status:")
            for file in changed_files:
                self.log(f"  {file}")
    
    def start_update(self):
        """Start the update process in a separate thread"""
        threading.Thread(target=self.update_repository, daemon=True).start()
    
    def update_repository(self):
        """Update the repository"""
        try:
            self.progress.start()
            self.update_button.config(state="disabled")
            
            # Generate commit message if empty
            message = self.message_var.get().strip()
            if not message:
                message = self.updater.generate_commit_message()
                self.message_var.set(message)
            
            self.log("Starting repository update...")
            
            # Stage changes
            self.log("Staging changes...")
            success, output, error = self.updater.stage_changes()
            if not success:
                raise Exception(f"Failed to stage changes: {error}")
            self.log("✅ Changes staged successfully")
            
            # Commit changes
            self.log("Committing changes...")
            success, output, error = self.updater.commit_changes(message)
            if not success:
                raise Exception(f"Failed to commit changes: {error}")
            self.log("✅ Changes committed successfully")
            
            # Push changes
            self.log("Pushing to remote repository...")
            success, output, error = self.updater.push_changes(self.force_var.get())
            if not success:
                raise Exception(f"Failed to push changes: {error}")
            self.log("✅ Successfully pushed to remote repository!")
            
            self.log(f"🎉 Repository updated successfully!")
            self.log(f"Commit: {message}")
            self.log(f"Remote: {self.updater.get_remote_url()}")
            
            messagebox.showinfo("Success", "Repository updated successfully!")
            
        except Exception as e:
            self.log(f"❌ Error: {str(e)}")
            messagebox.showerror("Error", f"Update failed: {str(e)}")
        
        finally:
            self.progress.stop()
            self.update_button.config(state="normal")
            self.check_status()
    
    def run(self):
        """Run the GUI"""
        self.root.mainloop()

def cli_update(args):
    """Command line interface for updating"""
    updater = AutoUpdater()
    
    if not updater.is_git_repo:
        print("❌ Not a git repository!")
        return 1
    
    # Check for changes
    has_changes, output = updater.check_git_status()
    if not has_changes:
        print("✅ No changes detected. Repository is up to date.")
        return 0
    
    # Show changed files
    changed_files = updater.get_changed_files()
    print(f"📝 Found {len(changed_files)} changed files:")
    for file in changed_files:
        print(f"  {file}")
    
    # Generate commit message
    message = updater.generate_commit_message(args.message)
    print(f"📝 Commit message: {message}")
    
    if not args.yes:
        response = input("Proceed with update? (y/N): ")
        if response.lower() != 'y':
            print("Update cancelled.")
            return 0
    
    try:
        # Stage changes
        print("📦 Staging changes...")
        success, _, error = updater.stage_changes()
        if not success:
            print(f"❌ Failed to stage changes: {error}")
            return 1
        
        # Commit changes
        print("💾 Committing changes...")
        success, _, error = updater.commit_changes(message)
        if not success:
            print(f"❌ Failed to commit changes: {error}")
            return 1
        
        # Push changes
        print("🚀 Pushing to remote...")
        success, _, error = updater.push_changes(args.force)
        if not success:
            print(f"❌ Failed to push changes: {error}")
            return 1
        
        print("✅ Repository updated successfully!")
        print(f"Remote: {updater.get_remote_url()}")
        return 0
        
    except Exception as e:
        print(f"❌ Error: {str(e)}")
        return 1

def main():
    """Main entry point"""
    parser = argparse.ArgumentParser(description="AutoFish Pro Auto Update Tool")
    parser.add_argument("--gui", action="store_true", help="Launch GUI interface")
    parser.add_argument("--message", "-m", help="Custom commit message")
    parser.add_argument("--force", "-f", action="store_true", help="Force push")
    parser.add_argument("--yes", "-y", action="store_true", help="Auto-confirm updates")
    
    args = parser.parse_args()
    
    if args.gui or len(sys.argv) == 1:
        # Launch GUI
        try:
            gui = AutoUpdaterGUI()
            gui.run()
        except ImportError:
            print("❌ GUI not available. Install tkinter or use CLI mode.")
            return 1
    else:
        # Use CLI
        return cli_update(args)

if __name__ == "__main__":
    exit(main())
