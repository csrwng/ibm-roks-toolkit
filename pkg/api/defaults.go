package api

import (
	"github.com/google/uuid"
)

// NewClusterParams returns a new default cluster params struct
func NewClusterParams() *ClusterParams {
	p := &ClusterParams{}
	p.ImageRegistryHTTPSecret = uuid.New().String()
	return p
}
