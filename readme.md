# P5 HR App on SAP HANA Cloud

Project P5 of the clickERP live SAP CAP course (Units 7 and 8).

Step-by-step guide: [guide.md](guide.md)

A small HR app: employees and leave requests, with three roles.

| User  | Password | Roles              | Can do                                   |
| ----- | -------- | ------------------ | ---------------------------------------- |
| alice | alice    | Employee           | See and create her own leave requests    |
| bob   | bob      | Employee, Manager  | See everything, approve and reject       |
| carol | carol    | HRAdmin            | See and change everything                |

## Branches

| Branch  | What it holds |
| ------- | ------------- |
| `start` | The app on SQLite, with roles, validation and actions. Start Unit 8 here. |
| `end`   | The same app ready for SAP HANA Cloud (`cds add hana`), plus `db/explore.sql`. |

## Run it on SQLite

```bash
npm install
cds watch
```

Then open `test.http` and send the requests.

## Run it on SAP HANA Cloud

You need a running SAP HANA Cloud instance in your BTP trial, and a Cloud Foundry login in BAS.

```bash
cds add hana
npm install
cds deploy --to hana
cds watch --profile hybrid
```

`cds deploy --to hana` creates an HDI container called `hr-app-hana-db`, loads the tables and data,
and saves the connection in `.cdsrc-private.json`. That file is not in Git, so after a fresh clone run:

```bash
cds bind -2 hr-app-hana-db
cds watch --profile hybrid
```

Want live, instructor-led SAP training? Request a live session here: https://forms.gle/ovT9EgQquL5ERW2c6
