# SSH Key Pair
This directory holds the **SSH key-pair files**, the _Public (`.pub`)_ and the _Private (`.pem`)_ keys, when they're **created by Terraform**.

> [!CAUTION]  
> **SSH KEY-PAIR ARE CRITICAL AND SENSITIVE. Do not share with _unauthorised personnel_.**  
> By default, **"`.pem`"** and **"`.pub`"** files inside this directory are mentioned inside **`.gitignore`** for excluding from Git tracking.

> [!NOTE]  
> This README file allows Git repositories to have this folder **created or pre-existing for Terraform**. If you wish to remove this `README.md` file, you will need to ensure that `local_file` resources don't get errors because the `.ssh` doesn't exist.