using UnityEngine;
using UnityEditor;
using System.Collections;

/// <summary>
/// 通过镜头位置来渲染Cubemap
/// </summary>
public class RenderCubemapWizard : ScriptableWizard {
	
	public Transform renderFromPosition;
	public Cubemap cubemap;
	
	void OnWizardUpdate () {
		helpString = "Select transform to render from and cubemap to render into";
		isValid = (renderFromPosition != null) && (cubemap != null);
	}
	
	void OnWizardCreate () {
		GameObject go = new GameObject( "CubemapCamera");           // 创建临时相机
		go.transform.position = renderFromPosition.position;        // 将传进来的转换位置传给这个相机
        go.AddComponent<Camera>().RenderToCubemap(cubemap);         // 从各相机重新渲染到传进来的Cubemap
		
		DestroyImmediate( go );
	}
	
	[MenuItem("GameObject/Render into Cubemap")]
	static void RenderCubemap () {
        DisplayWizard<RenderCubemapWizard>("Render cubemap", "Render!");
	}
}