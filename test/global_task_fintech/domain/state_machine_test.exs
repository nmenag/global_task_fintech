defmodule GlobalTaskFintech.Domain.StateMachineTest do
  use GlobalTaskFintech.DataCase, async: true
  alias GlobalTaskFintech.Domain.StateMachine.TransitionEngine
  alias GlobalTaskFintech.Infrastructure.Repositories.CreditApplicationRepository

  describe "Mexico State Machine (MX)" do
    setup do
      app_attrs = %{
        country: "MX",
        status: :pending,
        full_name: "Test MX",
        document_type: "CURP",
        document_number: "ABCD123456EFGHIJ12",
        monthly_income: Decimal.new("10000"),
        amount_requested: Decimal.new("5000")
      }

      {:ok, attrs: app_attrs}
    end

    test "valid transition: pending -> risk_check", %{attrs: attrs} do
      {:ok, app} = CreditApplicationRepository.save(attrs)
      assert {:ok, updated} = TransitionEngine.transition(app, :risk_check)
      assert updated.status == :risk_check
    end

    test "valid transition: pending -> approved (automated)", %{attrs: attrs} do
      {:ok, app} = CreditApplicationRepository.save(attrs)
      assert {:ok, updated} = TransitionEngine.transition(app, :approved)
      assert updated.status == :approved
    end

    test "invalid transition: pending -> manual_review", %{attrs: attrs} do
      {:ok, app} = CreditApplicationRepository.save(attrs)
      assert {:error, :invalid_transition} = TransitionEngine.transition(app, :manual_review)
    end

    test "valid flow: pending -> risk_check -> manual_review", %{attrs: attrs} do
      {:ok, app} = CreditApplicationRepository.save(attrs)
      {:ok, app_rc} = TransitionEngine.transition(app, :risk_check)
      assert {:ok, app_mr} = TransitionEngine.transition(app_rc, :manual_review)
      assert app_mr.status == :manual_review
    end
  end

  describe "Colombia State Machine (CO)" do
    setup do
      app_attrs = %{
        country: "CO",
        status: :pending,
        full_name: "Test CO",
        document_type: "CC",
        document_number: "12345678",
        monthly_income: Decimal.new("5000000"),
        amount_requested: Decimal.new("1000000")
      }

      {:ok, attrs: app_attrs}
    end

    test "valid transition: pending -> manual_review", %{attrs: attrs} do
      {:ok, app} = CreditApplicationRepository.save(attrs)
      assert {:ok, updated} = TransitionEngine.transition(app, :manual_review)
      assert updated.status == :manual_review
    end

    test "invalid transition: pending -> risk_check", %{attrs: attrs} do
      {:ok, app} = CreditApplicationRepository.save(attrs)
      assert {:error, :invalid_transition} = TransitionEngine.transition(app, :risk_check)
    end
  end
end
