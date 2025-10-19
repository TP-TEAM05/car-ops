# ReCo CarOps – pypyr Pipeline Documentation

## 1  What is pypyr?

[pypyr](https://pypyr.io) is a lightweight, YAML‑driven task‑runner.  
A **pipeline** is just a YAML file that lists **steps** to run in order.  
Steps can call shell commands, write files, run Python, call other pipelines, etc.

ReCo uses pypyr on each car‑controller Raspberry Pi to automate setup,
configuration and CI‑style build/run tasks.

---

## 2  Repository layout

```
car-ops/
├─ pypyr/
│  ├─ default.yaml        # always present – bootstrap + Sentry
│  ├─ pipeline.yaml       # generated from USB/SD config (user‑defined)
│  ├─ example.yaml        # template you can copy when authoring pipeline.yaml
│  └─ README.md
├─ reco_config_monitor.sh # watches /media/RECO_CONFIG & starts pypyr
└─ …other scripts…
```

### Where does *pipeline.yaml* come from?

When you plug in a **RECO_CONFIG** USB/SD card the monitor script:

1. mounts the drive at `/media/RECO_CONFIG`;  
2. copies `pipeline.yaml` from the drive to `car-ops/pypyr/`;  
3. calls `pypyr default` to kick everything off.

---

## 3  Execution flow

```text
reco_config_monitor.sh          default.yaml                   pipeline.yaml
┌──────────────┐                ┌──────────────┐               ┌──────────────┐
│ Detect mount │──cp──────────▶ │ init Sentry  │               │  your steps  │
└──────────────┘                │ pype→pipeline│──runs──▶      └──────────────┘
                                │ make lock    │
                                │ on‑error→log │
                                └──────────────┘
```

1. **reco_config_monitor.sh** ensures only one instance via lock‑file and invokes  
   `pypyr default` inside `~/car-ops/pypyr`.
2. **default.yaml**  
   * initialises the Sentry SDK so every exception is captured;  
   * delegates to `pipeline.yaml` with `pypyr.steps.pype`;  
   * writes `/reco/run/pypyr.lock` so subsequent mounts don’t re‑run;  
   * has a final `runOnError: True` step that ships the stack‑trace to Sentry.
3. **pipeline.yaml** – completely user‑defined. This is where you describe how to
   configure the car for a specific experiment or CI run.

---

## 4  Common steps used in ReCo

| Step name            | Purpose in example pipeline |
|----------------------|------------------------------|
| `pypyr.steps.set`    | Define variables (e.g. `ROS_DOMAIN_ID`, IPs, VIN…). |
| `pypyr.steps.cmd`    | Start/stop ROS2 nodes, build work‑spaces, or any shell. |
| `pypyr.steps.filewrite` | Persist config to files that other processes read. |
| `pypyr.steps.pype`   | Call another pipeline (used by *default.yaml*). |
| `pypyr.steps.py`     | Run inline Python – used for Sentry & advanced logic. |

See the [pypyr step‑catalog](https://pypyr.io/docs/step-index/) for many more.

---

## 5  Authoring **pipeline.yaml**

Start from `pypyr/example.yaml`:

```yaml
# Minimal skeleton
steps:
  - name: pypyr.steps.set          # 1. declare your variables
    in:
      set:
        ROS_DOMAIN_ID: 2
        BACKEND_IP: 192.168.20.96
        …

  - name: pypyr.steps.cmd          # 2. stop anything from previous run
    in:
      cmd:
        run: "bash ~/car-ops/ros2/reco-stop.sh"

  - name: pypyr.steps.cmd          # 3. build workspace (logs to /reco/log)
    in:
      cmd:
        run: "colcon build"
        stderr: "/reco/log/colcon-build.log"

  - name: pypyr.steps.filewrite    # 4. propagate config
    in:
      fileWrite:
        path: "/home/ubuntu/ros_domain_id"
        payload: "{ROS_DOMAIN_ID}"
```

### Tips

* **Interpolation** – any `{Variable}` placeholder gets replaced with the value
  you set earlier with `pypyr.steps.set`.
* **Restart safety** – pipelines are idempotent if you encode logic like
  `rm -f /tmp/lock` or check whether a node is already running.
* **Dry‑run** – run `pypyr --dry-run pipeline` to list steps without executing.

---

## 6  Running pipelines manually

```bash
cd ~/car-ops/pypyr
pypyr default            # normal – goes via Sentry & lock
pypyr pipeline           # run your pipeline directly (bypasses Sentry)
pypyr example            # run the template
```

Use `-v` or `--log 10` to increase verbosity, and `--dry-run` to trace.

---

## 7  Sentry integration

*default.yaml* wires up the Sentry **DSN** & environment once per run.
Change the DSN by editing the `sentry_sdk.init()` block in default.yaml.

Any unhandled exception – including one thrown in your custom pipeline – will
reach the “Error handling” step and be captured.

---

## 8  Troubleshooting

| Symptom                              | Fix |
|--------------------------------------|-----|
| `Script already executed…` error     | Remove `/reco/run/reco_config_monitor.lock` if safe and rerun. |
| `pypyr.steps.cmd` step hangs         | Add `timeout` to your shell command or run it in the background (`&`). |
| Pipeline doesn’t start               | Confirm `pipeline.yaml` was copied; check `/reco/log/reco_config_monitor.log`. |
| Sentry shows no events               | Verify internet connectivity & DSN string. |
| Need to re‑run with new config       | Unmount RECO_CONFIG, update pipeline.yaml, re‑insert drive (or run manually). |

---

## 9  Further reading

* pypyr docs: <https://pypyr.io>
* Step index: <https://pypyr.io/docs/step-index/>
* ReCo CarOps README – base setup & service wiring.

