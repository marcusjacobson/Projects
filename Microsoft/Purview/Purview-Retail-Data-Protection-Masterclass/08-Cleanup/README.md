# Cleanup and Reset

This section contains scripts and instructions for cleaning up the lab environment and resetting configuration files to their default state.

## 🧹 Scripts

### Reset-GlobalConfig.ps1

This script resets the `templates/global-config.json` file to its generic state by copying the content from `templates/global-config.template.json`.

**Usage:**

```powershell
# Navigate to the directory
cd 08-Cleanup

# Run the script
.\Reset-GlobalConfig.ps1
```

**Purpose:**
- Removes personal Tenant IDs and Subscription IDs from the configuration file.
- Prepares the repository for a new user or a fresh run of the masterclass.
- Ensures no sensitive information is accidentally committed if the config file is tracked (though it should be ignored).

---

## 🤖 AI-Assisted Content Generation

This documentation was created with the assistance of **GitHub Copilot** powered by advanced AI language models. The content was generated, structured, and refined through iterative collaboration between human expertise and AI assistance within **Visual Studio Code**.

*AI tools were used to enhance productivity and ensure comprehensive coverage of cleanup procedures.*
