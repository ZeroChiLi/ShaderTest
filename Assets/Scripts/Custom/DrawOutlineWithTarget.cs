using UnityEngine;

public class DrawOutlineWithTarget : PostEffectsBase
{
    public MeshFilter targetMeshFilter;

    [Range(0,1)]
    public float width = 0.05f;
    public Color color = Color.green;

    private void Update()
    {
        if (TargetMaterial != null && targetMeshFilter != null)
        {
            TargetMaterial.SetFloat("_Width", width);
            TargetMaterial.SetColor("_Color", color);

            Graphics.DrawMesh(targetMeshFilter.sharedMesh, targetMeshFilter.transform.localToWorldMatrix, TargetMaterial, 0);
        }

    }



}
