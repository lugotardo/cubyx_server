// More Blocks Mod
// Adiciona blocos customizados ao jogo via block.toml
// Os blocos são registrados automaticamente pelo sistema de manifesto

fn on_init() {
    log("[More Blocks] Mod carregado! Blocos customizados disponíveis.");
}

fn on_tick(tick) {
    // Este mod não precisa de lógica por tick
    // Os blocos são puramente definidos via TOML
}

fn on_event(event_type, data) {
    // Sem lógica de evento
}
