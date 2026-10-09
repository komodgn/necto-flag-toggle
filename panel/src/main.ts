//
// Flag Toggle panel.
//
// Display strings (title/onLabel/offLabel/note) come from the app-injected config (flag.config).
// Value changes go through the flag.get/toggle/enable/disable/reset device bridges.
//

import { isNectoBridgeError, necto } from "@necto/bridge";
import { t } from "./localization";

interface FlagState {
  on: boolean;
}

interface FlagConfig {
  title: string;
  onLabel: string;
  offLabel: string;
  note: string;
}

const config: FlagConfig = { title: "Flag Toggle", onLabel: "ON", offLabel: "OFF", note: "" };

const el = (id: string) => document.getElementById(id);

for (const element of document.querySelectorAll<HTMLElement>("[data-i18n]")) {
  element.textContent = t(element.dataset.i18n ?? "");
}

function renderState(state: FlagState): void {
  const toggle = el("toggle");
  if (toggle) toggle.setAttribute("aria-checked", String(state.on));

  const target = el("state");
  if (!target) return;
  target.textContent = state.on ? config.onLabel : config.offLabel;
  // Shape carries the state alongside the hue: a filled mark when on, a ring when off.
  target.className = `necto-status necto-row-value ${state.on ? "necto-status-ok" : "necto-status-idle"}`;
}

function applyConfig(next: FlagConfig): void {
  Object.assign(config, next);
  const title = el("title");
  if (title) title.textContent = config.title;
  const note = el("note");
  if (note) note.textContent = config.note;
  const enable = el("enable");
  if (enable) enable.textContent = config.onLabel;
  const disable = el("disable");
  if (disable) disable.textContent = config.offLabel;
}

async function call(op: string): Promise<void> {
  const target = el("state");
  try {
    const state = await necto.device.send<FlagState & Record<string, never>>(op);
    renderState(state);
  } catch (error) {
    if (target) {
      target.className = "necto-status necto-row-value necto-status-danger";
      target.textContent = isNectoBridgeError(error) ? `${error.code}: ${error.message}` : String(error);
    }
  }
}

el("toggle")?.addEventListener("click", () => void call("flag.toggle"));
el("enable")?.addEventListener("click", () => void call("flag.enable"));
el("disable")?.addEventListener("click", () => void call("flag.disable"));
el("refresh")?.addEventListener("click", () => void call("flag.get"));

async function main(): Promise<void> {
  if (!necto.isAvailable()) return;
  try {
    applyConfig(await necto.device.send<FlagConfig & Record<string, never>>("flag.config"));
  } catch {
    // keep defaults if config is unavailable
  }
  await call("flag.get");
  await necto.ready();
}

void main();
