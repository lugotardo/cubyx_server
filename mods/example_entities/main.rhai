// Example Entities Mod
// Demonstra o sistema de entidades controladas por script.
// Define comportamentos para slime e merchant usando hooks on_entity_update_<type>.

// ═══════════════════════════════════════
// Configuração global do mod
// ═══════════════════════════════════════

let config_speed = mod_config("slime_speed");
let SLIME_SPEED = if config_speed == () { 1.0 } else { config_speed };

let config_range = mod_config("slime_aggro_range");
let AGGRO_RANGE = if config_range == () { 8.0 } else { config_range };

// ═══════════════════════════════════════
// Lifecycle hooks
// ═══════════════════════════════════════

fn on_init() {
    log("[ExampleEntities] Mod carregado!");
    log("[ExampleEntities] Slime speed: " + SLIME_SPEED);
    log("[ExampleEntities] Aggro range: " + AGGRO_RANGE);

    // Inscreve para receber eventos de entidades
    subscribe("entity_spawned");
    subscribe("entity_damaged");
}

fn on_tick(tick) {
    // Este mod não precisa de on_tick global —
    // a lógica é per-entity via on_entity_update_*
}

fn on_event(event_type, data) {
    if event_type == "entity_spawned" {
        log("[ExampleEntities] Entidade spawnada: " + data);
    }
}

// ═══════════════════════════════════════
// Entity Behavior: Slime
// ═══════════════════════════════════════
// Chamado pelo ScriptControlled system a cada tick_interval do slime.
// ctx = #{ id, x, y, z, state }
// Retorna: #{ actions, state_updates }

fn on_entity_update_slime(ctx) {
    let state = ctx.state;
    let x = ctx.x;
    let y = ctx.y;
    let z = ctx.z;

    // Estado inicial
    let phase = if state.phase == () { "idle" } else { state.phase };
    let idle_timer = if state.idle_timer == () { 0 } else { state.idle_timer };

    let result = #{
        actions: [],
        state_updates: #{}
    };

    // FSM simples
    if phase == "idle" {
        // Slime fica parado por 10 ticks, depois se move
        if idle_timer >= 10 {
            result.state_updates.phase = "wander";
            result.state_updates.idle_timer = 0;

            // Procura entidades próximas para aggro
            let nearby = entities_near(x, y, z, AGGRO_RANGE);
            if nearby.len() > 0 {
                result.state_updates.phase = "chase";
                result.state_updates.target_x = nearby[0].x;
                result.state_updates.target_y = nearby[0].y;
            }
        } else {
            result.state_updates.idle_timer = idle_timer + 1;
        }
    } else if phase == "wander" {
        // Move em direção aleatória (baseado em posição para ser determinístico)
        let dir_x = ((x * 7 + z * 13) % 3) - 1;
        let dir_y = ((y * 11 + z * 5) % 3) - 1;

        let new_x = x + dir_x;
        let new_y = y + dir_y;

        // Verifica se o destino é válido (tem bloco abaixo)
        let below = world_get_block(new_x, new_y, z - 1);
        if below != () {
            result.actions.push(#{
                type: "move",
                x: new_x,
                y: new_y,
                z: z
            });
        }

        result.state_updates.phase = "idle";
        result.state_updates.idle_timer = 0;
    } else if phase == "chase" {
        // Move em direção ao target
        let tx = if state.target_x == () { x } else { state.target_x };
        let ty = if state.target_y == () { y } else { state.target_y };

        let dx = if tx > x { 1 } else if tx < x { -1 } else { 0 };
        let dy = if ty > y { 1 } else if ty < y { -1 } else { 0 };

        result.actions.push(#{
            type: "move",
            x: x + dx,
            y: y + dy,
            z: z
        });

        // Volta para idle após perseguir
        result.state_updates.phase = "idle";
        result.state_updates.idle_timer = 0;
    }

    result
}

// ═══════════════════════════════════════
// Entity Behavior: Merchant
// ═══════════════════════════════════════
// NPC estático que reage quando jogador está perto.

fn on_entity_update_merchant(ctx) {
    let state = ctx.state;
    let x = ctx.x;
    let y = ctx.y;
    let z = ctx.z;

    let result = #{
        actions: [],
        state_updates: #{}
    };

    // Detecta jogadores próximos
    let nearby = entities_near(x, y, z, 4.0);

    if nearby.len() > 0 {
        // Jogador perto — emite evento de greeting
        let greeted = if state.greeted == () { false } else { state.greeted };
        if !greeted {
            emit_event("merchant_greeting", #{
                merchant_x: x,
                merchant_y: y,
                message: "Bem-vindo!"
            });
            result.state_updates.greeted = true;
        }
    } else {
        // Jogador saiu — reset greeting
        result.state_updates.greeted = false;
    }

    result
}
