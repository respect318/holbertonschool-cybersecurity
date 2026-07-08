from core.logger import get_logger

class Orchestrator:
    def __init__(self, state, scope=None):
        self.state = state
        self.modules = {}
        self.logger = get_logger("Orchestrator")
        
    def register(self, module):
        self.modules[module.name] = module
        
    def execute(self):
        order = ["dns", "subdomain", "portscan", "http", "tls"]
        for name in order:
            if name in self.modules:
                self.logger.info(f"Starting module: {name}")
                try:
                    self.modules[name].run(self.state)
                except TimeoutError as e:
                    # Timeout caught, logged, pipeline continue next
                    self.logger.error(f"Timeout error in {name}: {e}")
                    continue
                except Exception as e:
                    self.logger.error(f"Error in {name}: {e}")
                    continue
