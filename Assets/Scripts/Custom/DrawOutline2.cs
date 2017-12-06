using UnityEngine;

public class DrawOutline2 : PostEffectsBase
{
    public GameObject[] targets;

    [Range(0,1)]
    public float width = 0.05f;
    public Color color = Color.green;

    private MeshFilter[] meshFilters;

    private void Update()
    {
        if (TargetMaterial != null && targets != null)
        {
            TargetMaterial.SetFloat("_Width", width);
            TargetMaterial.SetColor("_Color", color);

            for (int i = 0; i < targets.Length; i++)
            {
                if (targets[i] == null)
                    continue;
                meshFilters = targets[i].GetComponentsInChildren<MeshFilter>();
                for (int j = 0; j < meshFilters.Length; j++)
                    Graphics.DrawMesh(meshFilters[j].sharedMesh, meshFilters[j].transform.localToWorldMatrix, TargetMaterial, 0);
            }
        }
    }
}
