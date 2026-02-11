package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

func EnableCmd() *cobra.Command {
	cmd := &cobra.Command{
		Use:        "enable",
		Short:      "Enable GLM settings for Claude",
		Long:       "Configure Claude to use GLM model via BigModel API",
		Deprecated: "GLM now uses temporary session-based configuration. Just run 'glm' to launch Claude with GLM.",
		RunE: func(cmd *cobra.Command, args []string) error {
			fmt.Println("⚠️  Warning: This command is deprecated.")
			fmt.Println("💡 'glm enable' is now a no-op.")
			fmt.Println("💡 Just run 'glm' to launch Claude with temporary session-based GLM configuration.")
			return nil
		},
	}

	cmd.Flags().StringP("model", "m", "", "Deprecated flag (no effect)")

	return cmd
}
