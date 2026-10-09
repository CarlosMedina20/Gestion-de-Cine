namespace GestionCine_WindowsForms;

public static class VentanaAdaptable
{
    // Tamaño inicial limitado al espacio real del escritorio (barra de tareas excluida).
    public static void Preparar(Form formulario, int ancho=960, int alto=600)
    {
        Rectangle area=Screen.FromControl(formulario).WorkingArea;
        int disponibleAncho=Math.Max(620,area.Width-40);
        int disponibleAlto=Math.Max(430,area.Height-40);
        int minimoAncho=Math.Min(760,disponibleAncho);
        int minimoAlto=Math.Min(480,disponibleAlto);
        formulario.MinimumSize=new Size(minimoAncho,minimoAlto);
        formulario.Size=new Size(Math.Min(ancho,disponibleAncho),Math.Min(alto,disponibleAlto));
        formulario.StartPosition=FormStartPosition.CenterScreen;
        formulario.AutoScaleMode=AutoScaleMode.Font;
        formulario.Shown+=(_,_)=>
        {
            Rectangle visible=Screen.FromControl(formulario).WorkingArea;
            int w=Math.Min(formulario.Width,Math.Max(620,visible.Width-24));
            int h=Math.Min(formulario.Height,Math.Max(430,visible.Height-24));
            formulario.Size=new Size(w,h);
            formulario.Location=new Point(visible.Left+(visible.Width-w)/2,visible.Top+(visible.Height-h)/2);
        };
    }
}
