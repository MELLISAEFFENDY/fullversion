#!/usr/bin/env python3
"""
AutoFish Pro - GUI Auto Update Tool
Advanced auto-updater with graphical interface
"""

import tkinter as tk
from tkinter import ttk, messagebox, scrolledtext
import subprocess
import os
import threading
from datetime import datetime
import sys

class AutoUpdateGUI:
    def __init__(self, root):
        self.root = root
        self.root.title("🎣 AutoFish Pro - Auto Update Tool")
        self.root.geometry("600x500")
        self.root.resizable(True, True)
        
        # Configuration
        self.git_path = "C:\\Git\\cmd\\git.exe"
        self.repo_path = "D:\\ssciprtgame\\New folder"
        self.branch = "main"
        
        self.setup_ui()
        self.check_git_status()
    
    def setup_ui(self):
        # Main frame
        main_frame = ttk.Frame(self.root, padding="10")
        main_frame.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Title
        title_label = ttk.Label(main_frame, text="🎣 AutoFish Pro - Auto Update Tool", 
                               font=("Arial", 16, "bold"))
        title_label.grid(row=0, column=0, columnspan=2, pady=(0, 20))
        
        # Repository info frame
        info_frame = ttk.LabelFrame(main_frame, text="Repository Information", padding="10")
        info_frame.grid(row=1, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        ttk.Label(info_frame, text="Repository:").grid(row=0, column=0, sticky=tk.W)
        ttk.Label(info_frame, text=self.repo_path).grid(row=0, column=1, sticky=tk.W, padx=(10, 0))
        
        ttk.Label(info_frame, text="Branch:").grid(row=1, column=0, sticky=tk.W)
        ttk.Label(info_frame, text=self.branch).grid(row=1, column=1, sticky=tk.W, padx=(10, 0))
        
        ttk.Label(info_frame, text="Git Path:").grid(row=2, column=0, sticky=tk.W)
        ttk.Label(info_frame, text=self.git_path).grid(row=2, column=1, sticky=tk.W, padx=(10, 0))
        
        # Commit message frame
        msg_frame = ttk.LabelFrame(main_frame, text="Commit Message", padding="10")
        msg_frame.grid(row=2, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(0, 10))
        
        self.commit_var = tk.StringVar(value=f"Auto-update: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        commit_entry = ttk.Entry(msg_frame, textvariable=self.commit_var, width=60)
        commit_entry.grid(row=0, column=0, sticky=(tk.W, tk.E))
        
        # Status frame
        status_frame = ttk.LabelFrame(main_frame, text="Repository Status", padding="10")
        status_frame.grid(row=3, column=0, columnspan=2, sticky=(tk.W, tk.E, tk.N, tk.S), pady=(0, 10))
        
        self.status_text = scrolledtext.ScrolledText(status_frame, height=15, width=70)
        self.status_text.grid(row=0, column=0, sticky=(tk.W, tk.E, tk.N, tk.S))
        
        # Buttons frame
        btn_frame = ttk.Frame(main_frame)
        btn_frame.grid(row=4, column=0, columnspan=2, pady=(10, 0))
        
        self.check_btn = ttk.Button(btn_frame, text="🔍 Check Status", command=self.check_status_threaded)
        self.check_btn.grid(row=0, column=0, padx=(0, 10))
        
        self.update_btn = ttk.Button(btn_frame, text="🚀 Update Repository", command=self.update_repository_threaded)
        self.update_btn.grid(row=0, column=1, padx=(0, 10))
        
        self.force_btn = ttk.Button(btn_frame, text="⚡ Force Update", command=self.force_update_threaded)
        self.force_btn.grid(row=0, column=2)
        
        # Progress bar
        self.progress = ttk.Progressbar(main_frame, mode='indeterminate')
        self.progress.grid(row=5, column=0, columnspan=2, sticky=(tk.W, tk.E), pady=(10, 0))
        
        # Configure grid weights
        self.root.columnconfigure(0, weight=1)
        self.root.rowconfigure(0, weight=1)
        main_frame.columnconfigure(0, weight=1)
        main_frame.rowconfigure(3, weight=1)
        status_frame.columnconfigure(0, weight=1)
        status_frame.rowconfigure(0, weight=1)
        msg_frame.columnconfigure(0, weight=1)
    
    def log_message(self, message):
        """Add message to status text widget"""
        self.status_text.insert(tk.END, f"[{datetime.now().strftime('%H:%M:%S')}] {message}\n")
        self.status_text.see(tk.END)
        self.root.update_idletasks()
    
    def run_git_command(self, args):
        """Run git command and return result"""
        try:
            cmd = [self.git_path] + args
            result = subprocess.run(cmd, cwd=self.repo_path, capture_output=True, text=True, timeout=30)
            return result.returncode == 0, result.stdout, result.stderr
        except subprocess.TimeoutExpired:
            return False, "", "Command timed out"
        except Exception as e:
            return False, "", str(e)
    
    def check_git_status(self):
        """Check if git is available and repository is valid"""
        if not os.path.exists(self.git_path):
            self.log_message("❌ Git not found at specified path")
            self.update_btn.config(state='disabled')
            self.force_btn.config(state='disabled')
            return False
        
        if not os.path.exists(self.repo_path):
            self.log_message("❌ Repository path not found")
            self.update_btn.config(state='disabled')
            self.force_btn.config(state='disabled')
            return False
        
        success, stdout, stderr = self.run_git_command(['status'])
        if not success:
            self.log_message("❌ Not a git repository or git error")
            self.update_btn.config(state='disabled')
            self.force_btn.config(state='disabled')
            return False
        
        self.log_message("✅ Git repository detected and ready")
        return True
    
    def check_status_threaded(self):
        """Check repository status in a separate thread"""
        threading.Thread(target=self.check_status, daemon=True).start()
    
    def check_status(self):
        """Check repository status"""
        self.progress.start()
        self.check_btn.config(state='disabled')
        
        try:
            self.log_message("🔍 Checking repository status...")
            
            # Check for changes
            success, stdout, stderr = self.run_git_command(['status', '--porcelain'])
            if not success:
                self.log_message(f"❌ Failed to check status: {stderr}")
                return
            
            if not stdout.strip():
                self.log_message("✅ No changes detected. Repository is up to date.")
                return
            
            self.log_message("📊 Changes detected:")
            for line in stdout.strip().split('\n'):
                if line:
                    status = line[:2]
                    file_path = line[3:]
                    status_icon = {
                        ' M': '📝', 'M ': '📝', 'A ': '➕', 'D ': '🗑️', 
                        'R ': '📁', '??': '🆕'
                    }.get(status, '📄')
                    self.log_message(f"  {status_icon} {file_path}")
            
            # Show current branch
            success, stdout, stderr = self.run_git_command(['branch', '--show-current'])
            if success and stdout.strip():
                self.log_message(f"🌿 Current branch: {stdout.strip()}")
            
        except Exception as e:
            self.log_message(f"❌ Error checking status: {str(e)}")
        finally:
            self.progress.stop()
            self.check_btn.config(state='normal')
    
    def update_repository_threaded(self):
        """Update repository in a separate thread"""
        threading.Thread(target=self.update_repository, daemon=True).start()
    
    def force_update_threaded(self):
        """Force update repository in a separate thread"""
        threading.Thread(target=lambda: self.update_repository(force=True), daemon=True).start()
    
    def update_repository(self, force=False):
        """Update repository with commit and push"""
        self.progress.start()
        self.update_btn.config(state='disabled')
        self.force_btn.config(state='disabled')
        
        try:
            commit_message = self.commit_var.get().strip()
            if not commit_message:
                commit_message = f"Auto-update: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}"
            
            if not force:
                # Check for changes first
                success, stdout, stderr = self.run_git_command(['status', '--porcelain'])
                if not success:
                    self.log_message(f"❌ Failed to check status: {stderr}")
                    return
                
                if not stdout.strip():
                    self.log_message("✅ No changes to commit. Repository is up to date.")
                    return
            
            self.log_message("🔄 Starting repository update...")
            self.log_message(f"💬 Commit message: {commit_message}")
            
            # Stage all changes
            self.log_message("📋 Staging changes...")
            success, stdout, stderr = self.run_git_command(['add', '.'])
            if not success:
                self.log_message(f"❌ Failed to stage changes: {stderr}")
                return
            
            # Commit changes
            self.log_message("💾 Committing changes...")
            success, stdout, stderr = self.run_git_command(['commit', '-m', commit_message])
            if not success:
                if "nothing to commit" in stderr:
                    self.log_message("✅ No changes to commit. Repository is up to date.")
                    return
                else:
                    self.log_message(f"❌ Failed to commit: {stderr}")
                    return
            
            # Push to remote
            self.log_message("🚀 Pushing to remote repository...")
            success, stdout, stderr = self.run_git_command(['push', 'origin', self.branch])
            if not success:
                self.log_message(f"❌ Failed to push: {stderr}")
                return
            
            self.log_message("✅ Repository updated successfully!")
            self.log_message("🎉 Changes have been pushed to GitHub")
            
            # Show final status
            success, stdout, stderr = self.run_git_command(['status', '--short'])
            if success and stdout.strip():
                self.log_message("📊 Remaining changes:")
                self.log_message(stdout)
            else:
                self.log_message("📊 Repository is clean")
            
            messagebox.showinfo("Success", "Repository updated successfully!")
            
        except Exception as e:
            self.log_message(f"❌ Error during update: {str(e)}")
            messagebox.showerror("Error", f"Update failed: {str(e)}")
        finally:
            self.progress.stop()
            self.update_btn.config(state='normal')
            self.force_btn.config(state='normal')

def main():
    root = tk.Tk()
    app = AutoUpdateGUI(root)
    
    # Handle window closing
    def on_closing():
        if messagebox.askokcancel("Quit", "Do you want to quit?"):
            root.destroy()
    
    root.protocol("WM_DELETE_WINDOW", on_closing)
    root.mainloop()

if __name__ == "__main__":
    main()
