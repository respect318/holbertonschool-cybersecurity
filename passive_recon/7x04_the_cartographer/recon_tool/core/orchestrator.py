#!/usr/bin/python3
"""
Pipeline Orchestrator for The Cartographer.
Resolves module dependencies and safely executes them.
"""
from core.logger import get_logger

class Orchestrator:
    def __init__(self, state, scope_guard=None):
        self.state = state
        self.scope = scope_guard
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
                    raise ValueError(f"Missing dependency: {dep} required by {name}")
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
            raise ValueError("Circular dependency detected! Pipeline execution aborted.")

        return execution_order

    def execute(self):
        """Execute modules safely, handling exceptions to preserve pipeline flow."""
        execution_order = self.resolve_dependencies()
        
        for name in execution_order:
            module = self.modules[name]
            self.logger.info(f"Starting execution of module: {name}")
            try:
                # Passing the shared state to the module's run method
                module.run(self.state)
                self.logger.info(f"Successfully finished module: {name}")
            except Exception as e:
                # Error handling: Catch exception, log it, and CONTINUE pipeline
                error_msg = f"Module {name} failed with exception: {str(e)}"
                self.logger.error(error_msg)
                self.state.errors.append(error_msg)
                
        return execution_order
