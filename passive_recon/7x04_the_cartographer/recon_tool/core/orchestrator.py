#!/usr/bin/python3
"""
Pipeline Orchestrator for The Cartographer.
Resolves dependencies and safely executes modules.
"""
from core.logger import get_logger


class Orchestrator:
    def __init__(self, state, scope=None):
        self.state = state
        self.scope = scope
        self.modules = {}
        self.logger = get_logger("Orchestrator")

    def register(self, module):
        """Register a module instance into the pipeline."""
        self.modules[module.name] = module

    def resolve_dependencies(self):
        """Perform topological sort and detect circular dependencies."""
        in_degree = {name: 0 for name in self.modules}
        adj_list = {name: [] for name in self.modules}

        for name, module in self.modules.items():
            for dep in module.dependencies:
                if dep not in self.modules:
                    raise ValueError(f"Missing dependency: {dep}")
                adj_list[dep].append(name)
                in_degree[name] += 1

        queue = [name for name in in_degree if in_degree[name] == 0]
        execution_order = []

        while queue:
            current = queue.pop(0)
            execution_order.append(current)

            for neighbor in adj_list[current]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

        if len(execution_order) != len(self.modules):
            raise ValueError("Circular dependency detected")

        return execution_order

    def execute(self):
        """Execute modules safely, catch exceptions, log errors, and continue."""
        execution_order = self.resolve_dependencies()
        
        for name in execution_order:
            module = self.modules[name]
            self.logger.info(f"Starting execution of module: {name}")
            try:
                # Passing the shared state to the module's run method
                module.run(self.state)
                self.logger.info(f"Successfully finished module: {name}")
            except Exception as e:
                # Catch the exception, log it, and continue to the next module
                error_msg = f"Module {name} failed: {str(e)}"
                self.logger.error(error_msg)
                self.state.errors.append(error_msg)
                continue
                
        return execution_order
