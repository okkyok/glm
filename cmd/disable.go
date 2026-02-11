package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

func DisableCmd() *cobra.Command {
	return &cobra.Command{
		Use:        "disable",
		Short:      "Disable GLM settings for Claude",
		Long:       "Remove GLM configuration and restore default Claude settings",
		Deprecated: "GLM now uses temporary session-based configuration. No need to disable - just run 'claude' directly.",
		RunE: func(cmd *cobra.Command, args []string) error {
			fmt.Println("⚠️  Warning: This command is deprecated.")
			fmt.Println("💡 'glm disable' is now a no-op.")
			fmt.Println("💡 To use Claude without GLM, run 'claude' directly.")
			return nil
		},
	}
}
