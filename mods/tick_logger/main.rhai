// Tick Logger Mod
// Loga informações do mundo periodicamente para debug
// Intervalo configurável via mod.toml

// Configuração do mod — lê da seção [config] do mod.toml
// Fallback para valor padrão caso a chave não exista
let config_interval = mod_config("log_interval");
let LOG_INTERVAL = if config_interval == () { 50 } else { config_interval };

fn on_init() {
    log("Tick Logger mod carregado!");
}

fn on_tick(tick) {
    if tick % LOG_INTERVAL != 0 {
        return;
    }

    let size = world_size();
    log("[TickLogger] Tick " + tick + " | Mundo: " + size[0] + "x" + size[1] + " | Altura max: " + world_max_height());
}

fn on_event(event_type, data) {
    log("[TickLogger] Event: " + event_type);

    if event_type == "block_placed" {
        let block_name = get_block_name(data.type_id);
        let name_str = if block_name == "" { "id:" + data.type_id } else { block_name };
        log("[TickLogger]   Position: (" + data.x + ", " + data.y + ", " + data.z + ") | block: " + name_str + " | variant: " + data.variant);
    }

    if event_type == "block_removed" {
        log("[TickLogger]   Position: (" + data.x + ", " + data.y + ", " + data.z + ")");
    }
}
