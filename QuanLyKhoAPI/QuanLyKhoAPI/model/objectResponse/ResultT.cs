namespace GioiThieuCty.Models.objResponse
{
    public class ResultT<T>
    {
        public bool IsSuccess { get; set; }
        public string? ErrorMessage { get; set; }
        public int Count { get; set; }
        public T? Data { get; set; }
    }
}