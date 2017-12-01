using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawOutline : PostEffectsBase
{
    public MeshFilter targetMesh;

    [Range(0, 2)]
    public float outlineWidth = 3f;
    public Color outlineColor = Color.green;

    private void Update()
    {
        if (targetMesh != null && TargetMaterial != null)
        {
            TargetMaterial.SetFloat("_Outline", outlineWidth);
            TargetMaterial.SetColor("_OutlineColor", outlineColor);
            Graphics.DrawMesh(targetMesh.mesh, targetMesh.transform.localToWorldMatrix, TargetMaterial, 0);
        }
    }

}
