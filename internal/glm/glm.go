package glm

import (
	"fmt"
)

func Enable(model, token string) error {
	_ = model
	_ = token
	fmt.Println("glm enable is deprecated and now a no-op. Run 'glm' for session-based launch.")
	return nil
}

func Disable() error {
	fmt.Println("glm disable is deprecated and now a no-op. Run 'claude' directly for default behavior.")
	return nil
}

func SetModel(model string) error {
	_ = model
	fmt.Println("glm set model via persistent settings is deprecated. Use 'glm --model <name>' per session.")
	return nil
}
