# Proxmox Backup Server (PBS) with TrueNAS NFS

> This guide explains how to configure and use **Proxmox Backup Server (PBS)** with a **TrueNAS NFS share** as a datastore.

## 1. Configure TrueNAS

1. Create a user with access to the NFS share.

   * Example: `backup`

2. Create a **dataset** in your TrueNAS pool.

3. Change the dataset owner to the user created above (`backup`).

4. Configure the NFS share:

   * Go to **Shares → NFS Shares** → *Add*.
   * Set **Path** to the dataset created in step 2.
   * Add a description.
   * Set **Hosts** to the IP address of the PBS server (restricting access for security).
   * Under **Advanced Options**, set **Maproot User** and **Maproot Group** to the user created in step 1 (`backup`).

## 2. Configure Proxmox Backup Server (PBS)

1. In PBS, go to **Configuration → Access Control** and create a user with the same name as on TrueNAS (`backup`).

2. Open the **shell** and create a folder where the TrueNAS dataset will be mounted:

   ```bash
   mkdir /mnt/pbs-backups
   ```

3. Edit the `fstab` file:

   ```bash
   nano /etc/fstab
   ```

4. Add the following line at the end of the file:

   ```bash
   <TrueNAS IP>:<TrueNAS dataset> <PBS folder> nfs vers=3,nouser,atime,auto,retrans=2,rw,dev,exec 0 0

   # Example
   10.10.10.10:/mnt/storage/pbs-backups /mnt/pbs-backups nfs vers=3,nouser,atime,auto,retrans=2,rw,dev,exec 0 0
   ```

5. Save and exit.

6. Mount the NFS share:

   ```bash
   mount -a
   ```

7. Test the mount:

   ```bash
   cd /mnt/pbs-backups
   touch test
   ```

   * Verify the `test` file appears on TrueNAS.
   * If successful, remove it:

     ```bash
     rm test
     ```

8. In PBS, go to **Datastore → Add Datastore**.

   * Set a **name**.
   * Set **Backing Path** to the PBS folder you created (`/mnt/pbs-backups`).

9. (Optional) Configure **Prune Options** to manage how many backups are kept.

   * Use the [Proxmox Backup Server Prune Simulator](https://pbs.proxmox.com/docs/prune-simulator/) to test different retention policies.

10. Add **Permissions**
    * Select newly created **Datastore → Permissions → Add**
    * Add roles `DatastoreAudit` and `DatastorePowerUser` for the user created above (`backup`)

## 3. Configure Proxmox VE

Once the PBS datastore is ready, add it as storage in your **Proxmox VE cluster**.

1. Go to **Datacenter → Storage → Add → Proxmox Backup Server**.
2. Fill in:

   * **ID**: name of the storage (e.g., `PBS`)
   * **Server**: IP or hostname of your PBS
   * **Datastore**: name of the PBS datastore (e.g., `pbs-backups`)
   * **Username**: PBS user (e.g., `backup@pbs`)
   * **Password**: PBS user password
3. Save.
