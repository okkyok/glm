package config

import (
	"encoding/json"
	"fmt"
	"os"

	"github.com/xqsit94/glm/pkg/paths"
)

type Config struct {
	AnthropicAuthToken string `json:"anthropic_auth_token"`
	DefaultModel       string `json:"default_model,omitempty"`
}

func Load() (*Config, error) {
	configPath := paths.GetConfigPath()

	if _, err := os.Stat(configPath); os.IsNotExist(err) {
		return &Config{}, nil
	}

	data, err := os.ReadFile(configPath)
	if err != nil {
		return nil, fmt.Errorf("failed to read config file: %v", err)
	}

	var config Config
	if err := json.Unmarshal(data, &config); err != nil {
		return nil, fmt.Errorf("failed to parse config file: %v", err)
	}

	return &config, nil
}

func Save(config *Config) error {
	configDir := paths.GetConfigDir()

	if err := os.MkdirAll(configDir, 0700); err != nil {
		return fmt.Errorf("failed to create config directory: %v", err)
	}

	data, err := json.MarshalIndent(config, "", "  ")
	if err != nil {
		return fmt.Errorf("failed to marshal config: %v", err)
	}

	configPath := paths.GetConfigPath()
	if err := os.WriteFile(configPath, data, 0600); err != nil {
		return fmt.Errorf("failed to write config file: %v", err)
	}

	return nil
}
