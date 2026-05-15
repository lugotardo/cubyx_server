// Auto-Grass Mod
// Converte blocos de dirt expostos (sem bloco acima) em grass
// a cada N ticks de simulação (configurável via mod.toml)

// Configuração do mod — lê da seção [config] do mod.toml
// Fallback para valor padrão caso a chave não exista
let config_interval = mod_config("grow_interval");
let GROW_INTERVAL = if config_interval == () { 100 } else { config_interval };

// Resolve IDs pelo nome para ser robusto a mudanças no manifesto de blocos
let DIRT_ID = get_block_id("dirt");
let GRASS_ID = get_block_id("grass");

// Fallback para IDs hardcoded se o mapa ainda não foi populado (segurança)
if DIRT_ID < 0 { DIRT_ID = 2; }
if GRASS_ID < 0 { GRASS_ID = 3; }

// Chamado uma vez ao carregar o mod
fn on_init() {
    log("Auto-Grass mod carregado!");
    log("Intervalo de crescimento: " + GROW_INTERVAL + " ticks");
}

// Chamado a cada tick da simulação
fn on_tick(tick) {
    // Só executa no intervalo configurado
    if tick % GROW_INTERVAL != 0 {
        return;
    }

    let size = world_size();
    let width = size[0];
    let depth = size[1];
    let max_h = world_max_height();
    let converted = 0;

    // Varre cada coluna (x, y) de cima para baixo
    for x in range(0, width) {
        for y in range(0, depth) {
            // Encontra o bloco mais alto da coluna
            for z in range(0, max_h) {
                let check_z = max_h - 1 - z;
                let block = world_get_block(x, y, check_z);

                if block != () {
                    // Se o bloco do topo é dirt, troca por grass
                    if block.type_id == DIRT_ID {
                        place_block(x, y, check_z, GRASS_ID);
                        converted += 1;
                    }
                    break;  // só o bloco mais alto de cada coluna
                }
            }
        }
    }

    if converted > 0 {
        log("[Auto-Grass] Tick " + tick + ": " + converted + " blocos convertidos para grass");
    }
}

// Chamado quando um evento acontece no mundo
fn on_event(event_type, data) {
    if event_type == "block_placed" {
        // Se o bloco colocado é dirt, verifica se pode virar grass
        if data.type_id == DIRT_ID {
            let x = data.x;
            let y = data.y;
            let z = data.z;

            // Verifica se não há bloco sólido acima
            let above = world_get_block(x, y, z + 1);
            if above == () {
                // Converte dirt para grass imediatamente
                place_block(x, y, z, GRASS_ID);
                log("[Auto-Grass] Dirt colocado em (" + x + ", " + y + ", " + z + ") → convertido para grass instantaneamente");
            }
        }
    }
}
