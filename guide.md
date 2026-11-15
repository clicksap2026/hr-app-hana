# P5 HR App, Part 2: Move Your Data to SAP HANA Cloud

Your HR app works. Employees create leave requests, and managers approve them.
But the data lives in **SQLite**, a small database inside your BAS dev space.
Restart the app, and every new request is gone. Nobody else can see it.

In this guide you move the same app to **SAP HANA Cloud**, SAP's real database in the cloud.
You change no code.

Time: about 45 minutes, plus 15 minutes of waiting while HANA starts up.

## Words you need

- **SAP BTP:** SAP's cloud platform. Your trial account is a BTP account.
- **Subaccount:** one working area inside your BTP account. Trial gives you one, called `trial`.
- **Cloud Foundry:** the place in BTP where CAP apps run. It has an **org**, and **spaces** inside it. You use the space `dev`.
- **Entitlement:** permission for a subaccount to use a service, such as HANA Cloud.
- **Service instance:** your own copy of a service that your app uses. Your HANA database is one.
- **Subscription:** a ready-made SAP app you just open. BAS is one.
- **Role collection:** a bundle of permissions you give to a user.
- **SAP HANA Cloud:** SAP's database in the cloud. It keeps data in memory, so it is fast.
- **HDI container:** your app's own private space inside HANA. Your tables live there.
- **Hybrid testing:** the app runs in BAS, but uses the real database in the cloud.

## Before you start

- A BTP trial account in **US East (US10)**. Other regions don't offer HANA Cloud on trial.
- A BAS dev space of type **Full Stack Cloud Application**, running.

## Step 1: Create your SAP HANA Cloud instance

Do this first. It takes 10 to 15 minutes to build, so the next steps run while you wait.

1. Open your trial subaccount. Go to **Services → Service Marketplace → SAP HANA Cloud → Create**.
   Choose plan **tools** and click **Create**.
2. Go to **Security → Users**. Open your user, click **Assign Role Collection**, and tick **SAP HANA Cloud Administrator**.
3. Go back to **Service Marketplace → SAP HANA Cloud → Create**.
   Plan **hana**, runtime **Cloud Foundry**, space **dev**, name `hana-trial`.
   Click **Configure instance parameters**. This opens SAP HANA Cloud Central.
4. Choose **SAP HANA Database**. Set a password for the DBADMIN user and write it down.
   Under connections, choose **Allow all IP addresses**. Click **Create**.

While it builds, carry on with Step 2.

## Step 2: Get the app and see the problem

In BAS, open a terminal:

```bash
git clone -b start https://github.com/clicksap2026/hr-app-hana.git
cd hr-app-hana
npm install
cds watch
```

Open `test.http` and click **Send Request** on request 3. A new leave request is created.

Now stop the app with **Ctrl+C**, and run `cds watch` again. Send request 1.
Your new request is gone. That is why we need a real database.

Stop the app again.

## Step 3: Log in to Cloud Foundry

Find your **API Endpoint** on the subaccount Overview page. On trial it looks like this:

```bash
cf login -a https://api.cf.us10-001.hana.ondemand.com
cf target -s dev
```

Enter your trial email and password.

## Step 4: Add HANA to the project

```bash
cds add hana
npm install
```

Open `package.json`. One line was added: `"@cap-js/hana"`, the HANA database driver.
That is the only change. Your model, service and handler stay the same.

## Step 5: Deploy your tables to HANA

In SAP HANA Cloud Central, check that `hana-trial` says **Running**. Then:

```bash
cds deploy --to hana
```

This does four things:

1. Turns your CDS model into HANA files, in the `gen/db` folder.
2. Creates an HDI container called `hr-app-hana-db`.
3. Creates your tables and loads the CSV data into them.
4. Saves the connection in `.cdsrc-private.json`.

Open `gen/db/src/gen/hr.LeaveRequests.hdbtable`. This is the table CAP wrote for you from your CDS.

## Step 6: Run the app against HANA

```bash
cds watch --profile hybrid
```

Look for this line in the terminal: `connect to db > hana`.

Send request 3 in `test.http` again. Stop the app, start it again with the same command, and send request 1.
Your request is still there. Your data now lives in HANA Cloud.

## Step 7: Look inside the database

1. In your subaccount, go to **Instances and Subscriptions**, open **SAP HANA Cloud**, and click **Go to Application**.
2. On `hana-trial`, choose **Actions → Open in SAP HANA Database Explorer**.
3. Click **+** (Add database). Type: **HDI Container**. Pick `hr-app-hana-db`.
4. Right-click it and open a **SQL Console**. Paste the queries from `db/explore.sql` and run them.

HANA writes table names in capital letters: `hr.LeaveRequests` becomes `HR_LEAVEREQUESTS`.

## Step 8: Connect again after a fresh clone

`.cdsrc-private.json` is listed in `.gitignore`, so it never goes to GitHub.
When you or a teammate clone the repo again, connect it to the same container:

```bash
cds bind -2 hr-app-hana-db
cds watch --profile hybrid
```

`cds bind` saves only a pointer. CAP fetches the password from Cloud Foundry when the app starts.

## Your task

Add a field `phone : String(20);` to `Employees` in `db/schema.cds`.

1. Run `cds watch --profile hybrid`. Is the new field in HANA yet? (Check in Database Explorer.)
2. Run `cds deploy --to hana`, then check again.
3. Commit and push your work to your own GitHub repo.

Answer: the field shows up in HANA only after `cds deploy --to hana`.

## If something goes wrong

| What you see | Fix |
| --- | --- |
| `cds deploy` cannot connect | Your HANA instance is stopped. Trial stops it every night. Start it in SAP HANA Cloud Central and wait for Running. |
| SAP HANA Cloud is not in the marketplace | Check **Entitlements**, and check that your trial is in US East (US10). |
| "Not logged in" or "No space targeted" | Run `cf login` and `cf target -s dev` again. |
| No access in SAP HANA Cloud Central | Assign the **SAP HANA Cloud Administrator** role collection, then log out and in again. |
| Hybrid run says no database credentials | Run `cds bind -2 hr-app-hana-db`. |

Stuck? Paste the full error into Claude in BAS and ask it to explain the error in simple words. Then check its answer before you follow it.

Want live, instructor-led SAP training? Request a live session here: https://forms.gle/ovT9EgQquL5ERW2c6
