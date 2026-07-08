#!/usr/bin/python3
"""
Module Base Interface for The Cartographer.
"""
from abc import ABC, abstractmethod

class ModuleBase(ABC):
    @property
    @abstractmethod
    def name(self) -> str:
        pass

    @property
    @abstractmethod
    def dependencies(self) -> list:
        pass

    @abstractmethod
    def run(self, state):
        pass
