#!/usr/bin/python3
"""
Pipeline Orchestrator for The Cartographer.
Resolves module dependencies and executes them in topological order.
"""


class Orchestrator:
    def __init__(self, state):
        self.state = state
        self.modules = {}

    def register(self, module):
        """Register a module instance into the pipeline."""
        self.modules[module.name] = module

    def resolve_dependencies(self):
        """
        Perform a topological sort to compute execution order 
        and detect any circular dependencies.
        """
        in_degree = {name: 0 for name in self.modules}
        adj_list = {name: [] for name in self.modules}

        # Build the graph based on declared dependencies
        for name, module in self.modules.items():
            for dep in module.dependencies:
                if dep not in self.modules:
                    raise ValueError(f"Missing dependency: {dep} required by {name}")
                adj_list[dep].append(name)
                in_degree[name] += 1

        # Queue modules with no dependencies (in-degree 0)
        queue = [name for name in in_degree if in_degree[name] == 0]
        execution_order = []

        while queue:
            current = queue.pop(0)
            execution_order.append(current)

            for neighbor in adj_list[current]:
                in_degree[neighbor] -= 1
                if in_degree[neighbor] == 0:
                    queue.append(neighbor)

        # If the sorted order doesn't include all modules, a cycle exists
        if len(execution_order) != len(self.modules):
            raise ValueError("Circular dependency detected! Pipeline execution aborted.")

        return execution_order

    def execute(self):
        """Execute the registered modules in the resolved topological order."""
        execution_order = self.resolve_dependencies()
        
        for name in execution_order:
            module = self.modules[name]
            try:
                module.run(self.state)
            except Exception as e:
                self.state.errors.append(f"Module {name} failed during execution: {str(e)}")
                
        return execution_order
